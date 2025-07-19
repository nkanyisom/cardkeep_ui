import 'package:flutter/material.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/api_service.dart';
import 'package:card_keep/services/sync_service.dart';

class CardService extends ChangeNotifier {
  final ApiService _apiService;
  final SyncService _syncService;

  List<LoyaltyCard> _cards = [];
  bool _isLoading = false;
  String? _errorMessage;

  CardService(this._apiService) : _syncService = SyncService();

  // Getters
  List<LoyaltyCard> get cards => List.unmodifiable(_cards);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all cards with offline support and enhanced error handling
  Future<bool> loadCards({BuildContext? context}) async {
    try {
      _setLoading(true);
      _clearError();

      // Use SyncService which handles offline/online automatically
      final cards = await _syncService.getCards(syncIfOnline: true);
      _cards = cards;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to load cards: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new card with offline support and enhanced error handling
  Future<bool> addCard(LoyaltyCard card, {BuildContext? context}) async {
    try {
      _setLoading(true);
      _clearError();

      // Use SyncService which handles offline/online automatically
      await _syncService.createCard(card);

      // Reload cards from cache instead of manually adding to list
      // This ensures we get the most up-to-date state from cache
      await loadCards();

      // Show success message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to add card: ${e.toString()}');

      // Show error message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a card with offline support and enhanced error handling
  Future<bool> deleteCard(
    int cardId, {
    String? cardName,
    BuildContext? context,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Use SyncService which handles offline/online automatically
      await _syncService.deleteCard(cardId);
      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();

      // Show success message
      if (context != null && context.mounted) {
        final message = cardName != null
            ? 'Card "$cardName" deleted successfully'
            : 'Card deleted successfully';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to delete card: ${e.toString()}');

      // Show error message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get a specific card by ID with offline support
  Future<LoyaltyCard?> getCard(int cardId, {BuildContext? context}) async {
    try {
      _setLoading(true);
      _clearError();

      // Try to find in local cache first
      final cachedCard = _cards.where((card) => card.id == cardId).firstOrNull;
      if (cachedCard != null) {
        return cachedCard;
      }

      // Fallback to API if not in cache
      return await _apiService.getCard(cardId, context: context);
    } catch (e) {
      _setError('Failed to get card: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Update a card with offline support and enhanced error handling
  Future<bool> updateCard(
    int cardId,
    LoyaltyCard updatedCard, {
    BuildContext? context,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Use SyncService which handles offline/online automatically
      final newCard = await _syncService.updateCard(cardId, updatedCard);

      // Update local list
      final index = _cards.indexWhere((c) => c.id == cardId);
      if (index != -1) {
        _cards[index] = newCard;
        notifyListeners();
      }

      // Show success message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Card updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to update card: ${e.toString()}');

      // Show error message
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update card: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Add a card locally (for testing or when offline)
  void addCardLocally(LoyaltyCard card) {
    _cards.add(card);
    notifyListeners();
  }

  /// Clear all cards
  void clearCards() {
    _cards.clear();
    notifyListeners();
  }

  /// Force refresh from sync service
  Future<bool> forceRefresh({BuildContext? context}) async {
    try {
      _setLoading(true);
      _clearError();

      final cards = await _syncService.forcSync();
      _cards = cards;
      notifyListeners();

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cards synced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      _setError('Failed to sync cards: ${e.toString()}');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}

// Extension for null-safe firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    return isEmpty ? null : first;
  }
}
