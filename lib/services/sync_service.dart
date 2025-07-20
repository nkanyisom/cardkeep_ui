import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../models/loyalty_card.dart';
import 'api_service.dart';
import 'offline_cache_service.dart';
import 'simple_auth_service.dart';

class SyncService extends ChangeNotifier {
  final ApiService _apiService;
  final OfflineCacheService _cacheService;
  final SimpleAuthService _authService;

  bool _isSyncing = false;
  String _syncStatus = 'idle';
  DateTime? _lastSyncTime;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SyncService(SimpleAuthService authService)
      : _authService = authService,
        _apiService = ApiService(authService),
        _cacheService = OfflineCacheService() {
    _initializeConnectivityListener();
  }

  // Getters
  bool get isSyncing => _isSyncing;
  String get syncStatus => _syncStatus;
  DateTime? get lastSyncTime =>
      _lastSyncTime ?? _cacheService.getLastSyncTime();

  /// Initialize connectivity listener for auto-sync
  void _initializeConnectivityListener() {
    _connectivitySubscription =
        _cacheService.connectivityStream.listen((result) {
      if (result != ConnectivityResult.none &&
          _cacheService.getPendingOperationsCount() > 0) {
        // Auto-sync when coming back online with pending changes
        syncWithBackend();
      }
    });
  }

  /// Dispose resources
  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Get sync status details
  Map<String, dynamic> getSyncStatusDetails() {
    final cacheDetails = _cacheService.getSyncStatusDetails();
    return {
      ...cacheDetails,
      'isSyncing': _isSyncing,
      'syncStatus': _syncStatus,
    };
  }

  /// Full sync with backend
  Future<List<LoyaltyCard>> syncWithBackend({bool force = false}) async {
    if (_isSyncing && !force) {
      debugPrint('Sync already in progress');
      return _cacheService.getAllCachedCards();
    }

    _setSyncStatus('syncing', true);

    try {
      // Check if user is authenticated
      if (!_authService.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      // Check connectivity
      if (!await _cacheService.isOnline()) {
        throw Exception('No internet connection');
      }

      // Get pending local changes before syncing
      final pendingCards = _cacheService.getCardsNeedingSync();

      // Push local changes first
      if (pendingCards.isNotEmpty) {
        await _pushLocalChanges(pendingCards);
      }

      // Pull latest data from server
      final serverCards = await _pullServerData();

      // Merge server data with any remaining local changes instead of replacing
      await _cacheService.mergeWithServerData(serverCards);

      _lastSyncTime = DateTime.now();
      _setSyncStatus('synced', false);

      debugPrint(
          'Sync completed successfully. ${serverCards.length} cards synced.');
      return _cacheService.getAllCachedCards();
    } catch (e) {
      debugPrint('Sync failed: $e');
      _setSyncStatus('error', false);

      // Return cached data even if sync failed
      return _cacheService.getAllCachedCards();
    }
  }

  /// Push local changes to server
  Future<void> _pushLocalChanges(List<LoyaltyCard> pendingCards) async {
    // Handle pending deletions first
    final pendingDeletions = _cacheService.getPendingDeletions();
    for (String cardId in pendingDeletions) {
      try {
        await _apiService.deleteCard(int.parse(cardId));
        await _cacheService.removePendingDeletion(cardId);
        debugPrint('Successfully deleted card $cardId from server');
      } catch (e) {
        debugPrint('Failed to delete card $cardId from server: $e');
        // Keep in pending deletions for next sync attempt
      }
    }

    // Handle card updates/creates
    for (var card in pendingCards) {
      try {
        if (card.id == null) {
          // Create new card
          final createdCard = await _apiService.createCard(card);
          // Remove old local card and add server card with ID
          await _cacheService.removeLocalCard(card);
          await _cacheService.cacheCard(createdCard.markAsSynced());
        } else {
          // Update existing card
          final updatedCard = await _apiService.updateCard(card.id!, card);
          await _cacheService.cacheCard(updatedCard.markAsSynced());
        }
      } catch (e) {
        debugPrint('Failed to sync card ${card.id}: $e');
        // Continue with other cards
      }
    }
  }

  /// Pull data from server
  Future<List<LoyaltyCard>> _pullServerData() async {
    return await _apiService.getCards();
  }

  /// Set sync status and notify listeners
  void _setSyncStatus(String status, bool syncing) {
    _syncStatus = status;
    _isSyncing = syncing;
    notifyListeners();
  }

  /// Get cards with offline support
  Future<List<LoyaltyCard>> getCards({bool syncIfOnline = true}) async {
    try {
      // Always return cached data first for immediate response
      final cachedCards = _cacheService.getAllCachedCards();

      // Try to sync if online and requested
      if (syncIfOnline &&
          await _cacheService.isOnline() &&
          _authService.isAuthenticated) {
        // Don't wait for sync, return cached data immediately
        syncWithBackend(); // Fire and forget
      }

      return cachedCards;
    } catch (e) {
      debugPrint('Error getting cards: $e');
      return _cacheService.getAllCachedCards();
    }
  }

  /// Create card with offline support
  Future<LoyaltyCard> createCard(LoyaltyCard card) async {
    try {
      // Always cache locally first
      final cardWithTimestamp = card.copyWith(
        createdAt: DateTime.now(),
        needsSync: true,
      );

      await _cacheService.cacheCard(cardWithTimestamp);

      // Try to sync if online
      if (await _cacheService.isOnline() && _authService.isAuthenticated) {
        try {
          final serverCard = await _apiService.createCard(card);
          final syncedCard = serverCard.markAsSynced();

          // Remove the local card and replace with server card
          await _cacheService.removeLocalCard(cardWithTimestamp);
          await _cacheService.cacheCard(syncedCard);

          return syncedCard;
        } catch (e) {
          debugPrint('Failed to create card on server: $e');
          // Return cached version
        }
      }

      return cardWithTimestamp;
    } catch (e) {
      debugPrint('Error creating card: $e');
      rethrow;
    }
  }

  /// Update card with offline support
  Future<LoyaltyCard> updateCard(int cardId, LoyaltyCard card) async {
    try {
      // Update locally first
      final updatedCard = card.copyWith(
        id: cardId,
        updatedAt: DateTime.now(),
        needsSync: true,
      );

      await _cacheService.updateCachedCard(updatedCard);

      // Try to sync if online
      if (await _cacheService.isOnline() && _authService.isAuthenticated) {
        try {
          final serverCard = await _apiService.updateCard(cardId, card);
          final syncedCard = serverCard.markAsSynced();
          await _cacheService.cacheCard(syncedCard);
          return syncedCard;
        } catch (e) {
          debugPrint('Failed to update card on server: $e');
          // Return cached version
        }
      }

      return updatedCard;
    } catch (e) {
      debugPrint('Error updating card: $e');
      rethrow;
    }
  }

  /// Delete card with offline support
  Future<void> deleteCard(int cardId) async {
    try {
      // Try to delete from server if online
      if (await _cacheService.isOnline() && _authService.isAuthenticated) {
        try {
          await _apiService.deleteCard(cardId);
          // Delete successful - now remove from cache
          await _cacheService.deleteCachedCard(cardId.toString());
          debugPrint('Card $cardId deleted from server and cache');
        } catch (e) {
          debugPrint('Failed to delete card from server: $e');
          // Keep the delete pending for next sync attempt
          await _cacheService.addPendingDeletion(cardId.toString());
          // Still remove from local cache to give user immediate feedback
          await _cacheService.deleteCachedCard(cardId.toString());
        }
      } else {
        // Offline - add to pending deletions and remove from local cache
        await _cacheService.addPendingDeletion(cardId.toString());
        await _cacheService.deleteCachedCard(cardId.toString());
        debugPrint('Card $cardId queued for deletion when online');
      }
    } catch (e) {
      debugPrint('Error deleting card: $e');
      rethrow;
    }
  }

  /// Get formatted sync status for UI
  String getFormattedSyncStatus() {
    if (_isSyncing) return 'Syncing...';

    final pendingOps = _cacheService.getPendingOperationsCount();
    if (pendingOps > 0) {
      return '$pendingOps changes pending sync';
    }

    return _cacheService.getFormattedLastSyncTime();
  }

  /// Force sync - useful for pull-to-refresh
  Future<List<LoyaltyCard>> forcSync() async {
    return await syncWithBackend(force: true);
  }

  /// Check if app is offline
  Future<bool> isOffline() async {
    return !await _cacheService.isOnline();
  }

  /// Get cards count for UI badges
  int getCardsCount() {
    return _cacheService.getAllCachedCards().length;
  }

  /// Get pending sync count for UI indicators
  int getPendingSyncCount() {
    return _cacheService.getPendingOperationsCount();
  }
}
