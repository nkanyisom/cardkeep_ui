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

    final Map<String, LoyaltyCard> cardsMap = {};
    for (var card in cards) {
      String key = card.id?.toString() ??
          'temp_${DateTime.now().millisecondsSinceEpoch}';
      String userSpecificKey = '${currentUser}_$key';
      cardsMap[userSpecificKey] = card;
    }
    await _cardsBox?.putAll(cardsMap);
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
    await _cardsBox?.delete(cardId);
  }

  /// Get cached card by ID
  LoyaltyCard? getCachedCard(String cardId) {
    return _cardsBox?.get(cardId);
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
    return getCardsNeedingSync().length;
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

    // Start with server data
    final List<LoyaltyCard> mergedCards = [];

    // Add all server cards (marked as synced)
    for (var serverCard in serverCards) {
      mergedCards.add(serverCard.markAsSynced());
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
}
