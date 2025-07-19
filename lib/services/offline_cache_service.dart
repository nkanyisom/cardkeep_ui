import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/loyalty_card.dart';

class OfflineCacheService {
  static const String _cardsBoxName = 'loyalty_cards';
  static const String _syncMetadataBoxName = 'sync_metadata';

  Box<LoyaltyCard>? _cardsBox;
  Box<dynamic>? _metadataBox;

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
  }

  // Cards Cache Operations

  /// Get all cached cards
  List<LoyaltyCard> getAllCachedCards() {
    return _cardsBox?.values.toList() ?? [];
  }

  /// Get cards that need sync
  List<LoyaltyCard> getCardsNeedingSync() {
    return _cardsBox?.values.where((card) => card.needsSync).toList() ?? [];
  }

  /// Cache a single card
  Future<void> cacheCard(LoyaltyCard card) async {
    String key =
        card.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    await _cardsBox?.put(key, card);
  }

  /// Cache multiple cards
  Future<void> cacheCards(List<LoyaltyCard> cards) async {
    final Map<String, LoyaltyCard> cardsMap = {};
    for (var card in cards) {
      String key = card.id?.toString() ??
          'temp_${DateTime.now().millisecondsSinceEpoch}';
      cardsMap[key] = card;
    }
    await _cardsBox?.putAll(cardsMap);
  }

  /// Update cached card
  Future<void> updateCachedCard(LoyaltyCard card) async {
    String key =
        card.id?.toString() ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    await _cardsBox?.put(key, card.markForSync());
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
    await _cardsBox?.clear();
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
    final Map<String, LoyaltyCard> mergedCards = {};

    // Add all server cards
    for (var serverCard in serverCards) {
      String key = serverCard.id?.toString() ??
          'server_${DateTime.now().millisecondsSinceEpoch}';
      mergedCards[key] = serverCard.markAsSynced();
    }

    // Preserve local cards that need sync (haven't been pushed to server yet)
    for (var localCard in localChanges) {
      if (localCard.id == null) {
        // This is a local-only card that hasn't been synced yet
        String key =
            'temp_${DateTime.now().millisecondsSinceEpoch}_${localCard.hashCode}';
        mergedCards[key] = localCard;
      } else {
        // This is an updated card that hasn't been synced yet
        String key = localCard.id.toString();
        mergedCards[key] = localCard; // Keep local changes
      }
    }

    // Clear cache and store merged data
    await _cardsBox?.clear();
    await _cardsBox?.putAll(mergedCards);

    await setLastSyncTime(DateTime.now());
    await setSyncStatus('synced');

    return mergedCards.values.toList();
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
