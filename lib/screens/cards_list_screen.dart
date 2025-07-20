import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/simple_auth_service.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/screens/add_card_screen.dart';
import 'package:card_keep/screens/barcode_scanner_screen.dart';
import 'package:card_keep/widgets/card_tile.dart';
import 'package:card_keep/widgets/sync_status_widget.dart';

class CardsListScreen extends StatefulWidget {
  const CardsListScreen({super.key});

  @override
  State<CardsListScreen> createState() => _CardsListScreenState();
}

class _CardsListScreenState extends State<CardsListScreen>
    with TickerProviderStateMixin {
  bool _isFabMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load cards when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CardService>().loadCards(context: context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _isFabMenuOpen = !_isFabMenuOpen;
    });
    if (_isFabMenuOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthService>(builder: (context, authService, child) {
      final currentUser = authService.currentUser;
      final userEmail = currentUser?['email'] ?? 'User';
      final userName = _extractUserName(userEmail);

      return Scaffold(
        appBar: AppBar(
          title: const Text('🚨 MEGA TEST - SCANNER VERSION 🚨',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          backgroundColor: Colors.yellow,
          elevation: 0,
          actions: [
            // SUPER OBVIOUS TEST BUTTON
            Container(
              margin: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () {
                  print('SCANNER BUTTON CLICKED!');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text('🔴 SCANNER 🔴',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            // Quick Scan Button - Enhanced visibility with text
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.qr_code_scanner,
                  size: 20,
                ),
                label: const Text(
                  'Scan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            // User profile section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      userName.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
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
            // TEST BANNER - Should be very visible
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.purple,
              child: Text(
                '� PURPLE MEGA TEST BANNER - SCANNER BUTTONS BELOW 🟣',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // SECOND TEST BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.orange,
              child: Text(
                '🟠 ORANGE BANNER - IF YOU SEE THIS, UI IS WORKING �',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Offline banner
            const OfflineBanner(),

            // Scanner Help Banner - Web visibility
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Scanner Access',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Tap "Scan" button above or use + button below',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Welcome and sync status section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $userName!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const SyncStatusWidget(),
                ],
              ),
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
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Icon(
                                Icons.credit_card,
                                size: 60,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No loyalty cards yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Keep all your loyalty cards in one place.\nNever lose them again!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 32),
                            FilledButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddCardScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Card'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Scanner Button - Between Add Card and Refresh Cards
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BarcodeScannerScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Scan Loyalty Card',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[600],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            OutlinedButton.icon(
                              onPressed: () =>
                                  cardService.loadCards(context: context),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Cards'),
                            ),
                          ],
                        ),
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
        floatingActionButton: Stack(
          children: [
            // Overlay to close menu when tapping outside
            if (_isFabMenuOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleFabMenu,
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
              ),
            // FAB Menu Items
            if (_isFabMenuOpen) ...[
              // Scan Card FAB
              Positioned(
                bottom: 140,
                right: 0,
                child: ScaleTransition(
                  scale: _animation,
                  child: FloatingActionButton(
                    heroTag: "scan",
                    onPressed: () {
                      _toggleFabMenu();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BarcodeScannerScreen(),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child:
                        const Icon(Icons.qr_code_scanner, color: Colors.white),
                  ),
                ),
              ),
              // Scan Card Label
              Positioned(
                bottom: 155,
                right: 72,
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Scan Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
              // Add Card FAB
              Positioned(
                bottom: 80,
                right: 0,
                child: ScaleTransition(
                  scale: _animation,
                  child: FloatingActionButton(
                    heroTag: "add",
                    onPressed: () {
                      _toggleFabMenu();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddCardScreen(),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              // Add Card Label
              Positioned(
                bottom: 95,
                right: 72,
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Add Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            // Main FAB
            FloatingActionButton(
              onPressed: _toggleFabMenu,
              child: AnimatedRotation(
                turns: _isFabMenuOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(_isFabMenuOpen ? Icons.close : Icons.add),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _extractUserName(String email) {
    // Extract name from email (part before @)
    String name = email.split('@')[0];
    // Capitalize first letter and replace dots/underscores with spaces
    name = name.replaceAll(RegExp(r'[._]'), ' ');
    return name
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
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
