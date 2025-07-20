import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/loyalty_card.dart';

class OfflineCacheService {
  static const String _cardsBoxName = 'loyalty_cards';
  static const String _syncMetadataBoxName = 'sync_metadata';
  static const String _currentUserKey = 'current_user_id';

  Box<LoyaltyCard>? _cardsBox;
  Box<dynamic>? _metadataBox;
  String? _currentUserId;

  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  /// Initialize Hive database
  Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(LoyaltyCardAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BarcodeTypeAdapter());
    }

    _cardsBox = await Hive.openBox<LoyaltyCard>(_cardsBoxName);
    _metadataBox = await Hive.openBox(_syncMetadataBoxName);
  }

  /// Close all boxes
  Future<void> close() async {
    await _cardsBox?.close();
    await _metadataBox?.close();
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    await _cardsBox?.clear();
    await _metadataBox?.clear();
    _currentUserId = null;
    print('🧹 All cache cleared');
  }

  /// Clear cards for current user only
  Future<void> clearCurrentUserCards() async {
    final currentUser = getCurrentUserId();
    if (currentUser == null) return;

    final keysToRemove = <String>[];
    if (_cardsBox != null) {
      for (var key in _cardsBox!.keys) {
        if (key.toString().startsWith('${currentUser}_')) {
          keysToRemove.add(key.toString());
        }
      }
    }

    for (var key in keysToRemove) {
      await _cardsBox?.delete(key);
    }
    print('🧹 Cleared ${keysToRemove.length} cards for user $currentUser');
  }

  /// Set current user for data isolation
  Future<void> setCurrentUser(String userId) async {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      await _metadataBox?.put(_currentUserKey, userId);
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    return _currentUserId ?? _metadataBox?.get(_currentUserKey);
  }

  /// Check if data belongs to current user
  bool _belongsToCurrentUser(String? dataUserId) {
    final currentUser = getCurrentUserId();
    return currentUser != null && dataUserId == currentUser;
  }

  // Cards Cache Operations

  /// Get all cached cards for current user
  List<LoyaltyCard> getAllCachedCards() {
    final currentUser = getCurrentUserId();
    if (currentUser == null) {
      print('⚠️ No current user set for cache retrieval');
      return [];
    }

    // Filter cards by checking if the key contains the current user ID
    final userCards = <LoyaltyCard>[];

    if (_cardsBox != null) {
      final allKeys = _cardsBox!.keys.toList();
      print('🔍 Cache has ${allKeys.length} total keys: ${allKeys.take(5)}');
      print(
          '🔍 Looking for user $currentUser keys with prefix "${currentUser}_"');

      for (var entry in _cardsBox!.toMap().entries) {
        if (entry.key.startsWith('${currentUser}_')) {
          userCards.add(entry.value);
        }
      }
    }

    print(
        '📦 Retrieved ${userCards.length} cached cards for user $currentUser');
    return userCards;
  }

  /// Get cards that need sync for current user
  List<LoyaltyCard> getCardsNeedingSync() {
    return getAllCachedCards().where((card) => card.needsSync).toList();
  }

  /// Cache a single card with user-specific key
  Future<void> cacheCard(LoyaltyCard card) async {
    final currentUser = getCurrentUserId();
    if (currentUser == null) return;

    String key =
        card.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    String userSpecificKey = '${currentUser}_$key';
    await _cardsBox?.put(userSpecificKey, card);
  }

  /// Cache multiple cards with user-specific keys
  Future<void> cacheCards(List<LoyaltyCard> cards) async {
    final currentUser = getCurrentUserId();
    if (currentUser == null) return;

    // Clear existing cards for current user first
    await clearCurrentUserCards();

    // Add new cards
    final Map<String, LoyaltyCard> cardsMap = {};
    for (var card in cards) {
      String key = card.id?.toString() ??
          'temp_${DateTime.now().millisecondsSinceEpoch}';
      String userSpecificKey = '${currentUser}_$key';
      cardsMap[userSpecificKey] = card;
    }
    await _cardsBox?.putAll(cardsMap);
    print('📦 Cached ${cards.length} cards for user $currentUser');
  }

  /// Update cached card with user-specific key
  Future<void> updateCachedCard(LoyaltyCard card) async {
    final currentUser = getCurrentUserId();
    if (currentUser == null) return;

    String key =
        card.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    String userSpecificKey = '${currentUser}_$key';
    await _cardsBox?.put(userSpecificKey, card.markForSync());
  }

  /// Remove a local card from cache (used when card is synced to server)
  Future<void> removeLocalCard(LoyaltyCard card) async {
    if (_cardsBox != null) {
      // Find and remove the card by comparing content since local cards might not have stable keys
      final keysToRemove = <String>[];
      for (var entry in _cardsBox!.toMap().entries) {
        final cachedCard = entry.value;
        if (cachedCard.cardName == card.cardName &&
            cachedCard.barcodeData == card.barcodeData &&
            cachedCard.barcodeType == card.barcodeType &&
            cachedCard.id == null && // Only remove local cards
            card.id == null) {
          keysToRemove.add(entry.key);
        }
      }
      for (var key in keysToRemove) {
        await _cardsBox?.delete(key);
      }
    }
  }

  /// Delete cached card
  Future<void> deleteCachedCard(String cardId) async {
    final currentUser = getCurrentUserId();
    if (currentUser == null) {
      print('⚠️ No current user set for card deletion');
      return;
    }

    String userSpecificKey = '${currentUser}_$cardId';
    await _cardsBox?.delete(userSpecificKey);
    print('🗑️ Deleted cached card with key: $userSpecificKey');
  }

  /// Get cached card by ID
  LoyaltyCard? getCachedCard(String cardId) {
    final currentUser = getCurrentUserId();
    if (currentUser == null) {
      print('⚠️ No current user set for card retrieval');
      return null;
    }

    String userSpecificKey = '${currentUser}_$cardId';
    return _cardsBox?.get(userSpecificKey);
  }

  // Sync Metadata Operations

  /// Get last sync timestamp
  DateTime? getLastSyncTime() {
    final timestamp = _metadataBox?.get('last_sync_time');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Update last sync timestamp
  Future<void> setLastSyncTime(DateTime time) async {
    await _metadataBox?.put('last_sync_time', time.millisecondsSinceEpoch);
  }

  /// Get sync status
  String getSyncStatus() {
    return _metadataBox?.get('sync_status', defaultValue: 'never_synced') ??
        'never_synced';
  }

  /// Update sync status
  Future<void> setSyncStatus(String status) async {
    await _metadataBox?.put('sync_status', status);
  }

  /// Get pending operations count
  int getPendingOperationsCount() {
    final pendingCards = getCardsNeedingSync().length;
    final pendingDeletes = getPendingDeletions().length;
    return pendingCards + pendingDeletes;
  }

  // Connectivity helpers

  /// Check if device is online
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Get connectivity status stream
  Stream<ConnectivityResult> get connectivityStream {
    return Connectivity().onConnectivityChanged;
  }

  // Sync helpers

  /// Mark all cards as synced
  Future<void> markAllAsSynced() async {
    final cards = getAllCachedCards();
    final syncedCards = cards.map((card) => card.markAsSynced()).toList();
    await cacheCards(syncedCards);
  }

  /// Replace cache with server data
  Future<void> replaceCacheWithServerData(List<LoyaltyCard> serverCards) async {
    // Use the user-specific cacheCards method which clears and caches with proper user keys
    final syncedCards = serverCards.map((card) => card.markAsSynced()).toList();
    await cacheCards(syncedCards);
    await setLastSyncTime(DateTime.now());
    await setSyncStatus('synced');
  }

  /// Merge server data with local changes
  Future<List<LoyaltyCard>> mergeWithServerData(
      List<LoyaltyCard> serverCards) async {
    final localChanges = getCardsNeedingSync();
    final pendingDeletions = getPendingDeletions();

    // Start with server data, but exclude cards pending deletion
    final List<LoyaltyCard> mergedCards = [];

    // Add server cards that are NOT pending deletion
    for (var serverCard in serverCards) {
      if (!pendingDeletions.contains(serverCard.id.toString())) {
        mergedCards.add(serverCard.markAsSynced());
      } else {
        print(
            '🚫 Excluding card ${serverCard.id} from merge - pending deletion');
      }
    }

    // Preserve local cards that need sync (haven't been pushed to server yet)
    for (var localCard in localChanges) {
      if (localCard.id == null) {
        // This is a local-only card that hasn't been synced yet
        mergedCards.add(localCard);
      } else {
        // This is an updated card that hasn't been synced yet
        // Replace the server version with local changes
        mergedCards.removeWhere((card) => card.id == localCard.id);
        mergedCards.add(localCard); // Keep local changes
      }
    }

    // Use the user-specific cacheCards method instead of direct cache manipulation
    await cacheCards(mergedCards);

    await setLastSyncTime(DateTime.now());
    await setSyncStatus('synced');

    print(
        '📊 Merged ${mergedCards.length} cards (excluded ${pendingDeletions.length} pending deletions)');
    return mergedCards;
  }

  /// Get formatted last sync time
  String getFormattedLastSyncTime() {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  /// Get sync status with details
  Map<String, dynamic> getSyncStatusDetails() {
    final lastSync = getLastSyncTime();
    final pendingOps = getPendingOperationsCount();
    final status = getSyncStatus();

    return {
      'status': status,
      'lastSync': lastSync,
      'formattedLastSync': getFormattedLastSyncTime(),
      'pendingOperations': pendingOps,
      'hasPendingChanges': pendingOps > 0,
    };
  }

  // Pending Deletion Operations

  /// Add card ID to pending deletions
  Future<void> addPendingDeletion(String cardId) async {
    try {
      List<String> pendingDeletes = getPendingDeletions();
      if (!pendingDeletes.contains(cardId)) {
        pendingDeletes.add(cardId);
        await _metadataBox?.put('pending_deletions', pendingDeletes);
        print('📝 Added card $cardId to pending deletions');
      }
    } catch (e) {
      print('⚠️ Error adding pending deletion: $e');
    }
  }

  /// Get list of card IDs pending deletion
  List<String> getPendingDeletions() {
    try {
      final deletions = _metadataBox?.get('pending_deletions');
      if (deletions is List) {
        return deletions.cast<String>();
      }
      return [];
    } catch (e) {
      print('⚠️ Error getting pending deletions: $e');
      return [];
    }
  }

  /// Remove card from pending deletions (called after successful server delete)
  Future<void> removePendingDeletion(String cardId) async {
    try {
      List<String> pendingDeletes = getPendingDeletions();
      pendingDeletes.remove(cardId);
      await _metadataBox?.put('pending_deletions', pendingDeletes);
      print('✅ Removed card $cardId from pending deletions');
    } catch (e) {
      print('⚠️ Error removing pending deletion: $e');
    }
  }

  /// Clear all pending deletions (useful for cleanup)
  Future<void> clearPendingDeletions() async {
    try {
      await _metadataBox?.delete('pending_deletions');
      print('🧹 Cleared all pending deletions');
    } catch (e) {
      print('⚠️ Error clearing pending deletions: $e');
    }
  }
}
