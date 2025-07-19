import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/simple_auth_service.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/screens/add_card_screen.dart';
import 'package:card_keep/widgets/card_tile.dart';
import 'package:card_keep/widgets/sync_status_widget.dart';

class CardsListScreen extends StatefulWidget {
  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardService>().loadCards(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Loyalty Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<SimpleAuthService>().signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          const OfflineBanner(),

          // Sync status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: const SyncStatusWidget(),
          ),

          // Cards list
          Expanded(
            child: Consumer<CardService>(
              builder: (context, cardService, child) {
                if (cardService.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (cardService.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          cardService.errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              cardService.loadCards(context: context),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (cardService.cards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No loyalty cards yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first loyalty card to get started',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddCardScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Card'),
                        ),
                      ],
                    ),
                  );
                }

                // Cards list with pull-to-refresh
                return RefreshIndicator(
                  onRefresh: () => _refreshCards(context, cardService),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cardService.cards.length,
                    itemBuilder: (context, index) {
                      final card = cardService.cards[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CardTile(
                          card: card,
                          onTap: () => _showCardDetails(context, card),
                          onDelete: () => _deleteCard(context, card),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCardScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Refresh cards with sync service
  Future<void> _refreshCards(
      BuildContext context, CardService cardService) async {
    await cardService.forceRefresh(context: context);
  }

  void _showCardDetails(BuildContext context, card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(card.cardName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: ${card.barcodeData}'),
            const SizedBox(height: 8),
            Text(
                'Type: ${BarcodeTypeHelper.enumToString(card.barcodeType).toUpperCase()}'),
            if (card.storeLogoUrl != null) ...[
              const SizedBox(height: 8),
              Text('Store: ${card.storeLogoUrl}'),
            ],
            const SizedBox(height: 8),
            Text(
                'Created: ${card.createdAt.toLocal().toString().split(' ')[0]}'),
            if (card.updatedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                  'Updated: ${card.updatedAt!.toLocal().toString().split(' ')[0]}'),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  card.needsSync ? Icons.sync_problem : Icons.sync,
                  size: 16,
                  color: card.needsSync ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  card.needsSync ? 'Pending sync' : 'Synced',
                  style: TextStyle(
                    color: card.needsSync ? Colors.orange : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteCard(BuildContext context, card) async {
    final confirmed = await _showDeleteConfirmation(context, card.cardName);
    if (confirmed && card.id != null) {
      final cardService = context.read<CardService>();
      await cardService.deleteCard(
        card.id!,
        cardName: card.cardName,
        context: context,
      );
    }
  }

  Future<bool> _showDeleteConfirmation(
      BuildContext context, String cardName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text('Are you sure you want to delete "$cardName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
