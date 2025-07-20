import 'package:flutter/material.dart';
import 'package:card_keep/models/loyalty_card.dart';

class CardTile extends StatelessWidget {
  final LoyaltyCard card;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CardTile({
    super.key,
    required this.card,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Card Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getCardColor(card.cardName, context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCardIcon(card.cardName, card.barcodeType),
                  size: 28,
                  color: _getCardIconColor(card.cardName, context),
                ),
              ),
              const SizedBox(width: 16),

              // Card Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Barcode Type: ${card.barcodeType.name}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Code: ${card.barcodeData}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Menu Button
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'view':
                      onTap?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('View Details'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBarcodeIcon(BarcodeType type) {
    switch (type) {
      case BarcodeType.qrCode:
        return Icons.qr_code;
      case BarcodeType.code128:
      case BarcodeType.code39:
      case BarcodeType.ean13:
      case BarcodeType.ean8:
      case BarcodeType.upca:
      case BarcodeType.upce:
        return Icons.barcode_reader;
      case BarcodeType.pdf417:
        return Icons.document_scanner;
    }
  }

  /// Get appropriate icon for the loyalty card, with special handling for South African cards
  IconData _getCardIcon(String cardName, BarcodeType barcodeType) {
    final cardNameLower = cardName.toLowerCase();

    // South African loyalty cards with specific icons
    if (cardNameLower.contains('pick n pay') ||
        cardNameLower.contains('pick\'n pay') ||
        cardNameLower.contains('picknpay')) {
      return Icons.shopping_cart; // Pick n Pay (grocery store)
    }
    if (cardNameLower.contains('checkers')) {
      return Icons.local_grocery_store; // Checkers (grocery store)
    }
    if (cardNameLower.contains('woolworths') ||
        cardNameLower.contains('woolies')) {
      return Icons.store; // Woolworths (premium retail)
    }
    if (cardNameLower.contains('clicks')) {
      return Icons.local_pharmacy; // Clicks (pharmacy/health)
    }
    if (cardNameLower.contains('dis-chem') ||
        cardNameLower.contains('dischem')) {
      return Icons.medical_services; // Dis-Chem (pharmacy)
    }
    if (cardNameLower.contains('spar')) {
      return Icons.shopping_basket; // SPAR (convenience store)
    }
    if (cardNameLower.contains('makro')) {
      return Icons.warehouse; // Makro (wholesale)
    }
    if (cardNameLower.contains('game')) {
      return Icons.sports_esports; // Game (electronics/games)
    }
    if (cardNameLower.contains('builder')) {
      return Icons.construction; // Builders (hardware store)
    }
    if (cardNameLower.contains('cashbuild')) {
      return Icons.home_repair_service; // Cashbuild (building supplies)
    }
    if (cardNameLower.contains('jet') || cardNameLower.contains('jet mart')) {
      return Icons.local_gas_station; // Jet (fuel/convenience)
    }
    if (cardNameLower.contains('engen')) {
      return Icons.local_gas_station; // Engen (fuel)
    }
    if (cardNameLower.contains('shell')) {
      return Icons.local_gas_station; // Shell (fuel)
    }
    if (cardNameLower.contains('bp')) {
      return Icons.local_gas_station; // BP (fuel)
    }
    if (cardNameLower.contains('caltex')) {
      return Icons.local_gas_station; // Caltex (fuel)
    }
    if (cardNameLower.contains('edgars')) {
      return Icons.checkroom; // Edgars (clothing)
    }
    if (cardNameLower.contains('truworths')) {
      return Icons.style; // Truworths (fashion)
    }
    if (cardNameLower.contains('mr price') || cardNameLower.contains('mrp')) {
      return Icons.shopping_bag; // Mr Price (clothing)
    }
    if (cardNameLower.contains('foschini')) {
      return Icons.local_mall; // Foschini (fashion retail)
    }
    if (cardNameLower.contains('ackermans')) {
      return Icons.family_restroom; // Ackermans (family clothing)
    }
    if (cardNameLower.contains('pep')) {
      return Icons.child_friendly; // PEP (clothing)
    }
    if (cardNameLower.contains('capitec')) {
      return Icons.account_balance; // Capitec Bank
    }
    if (cardNameLower.contains('fnb') ||
        cardNameLower.contains('first national')) {
      return Icons.account_balance; // FNB Bank
    }
    if (cardNameLower.contains('absa')) {
      return Icons.account_balance; // ABSA Bank
    }
    if (cardNameLower.contains('standard bank') ||
        cardNameLower.contains('standardbank')) {
      return Icons.account_balance; // Standard Bank
    }
    if (cardNameLower.contains('nedbank')) {
      return Icons.account_balance; // Nedbank
    }
    if (cardNameLower.contains('discovery')) {
      return Icons.health_and_safety; // Discovery (health/insurance)
    }
    if (cardNameLower.contains('momentum')) {
      return Icons.trending_up; // Momentum (financial services)
    }
    if (cardNameLower.contains('virgin active')) {
      return Icons.fitness_center; // Virgin Active (gym)
    }
    if (cardNameLower.contains('planet fitness')) {
      return Icons.sports_gymnastics; // Planet Fitness (gym)
    }
    if (cardNameLower.contains('kauai')) {
      return Icons.restaurant; // Kauai (health food)
    }
    if (cardNameLower.contains('mugg & bean') ||
        cardNameLower.contains('mugg and bean')) {
      return Icons.local_cafe; // Mugg & Bean (coffee shop)
    }
    if (cardNameLower.contains('vida')) {
      return Icons.coffee; // Vida e Caffè
    }
    if (cardNameLower.contains('steers')) {
      return Icons.fastfood; // Steers (burger chain)
    }
    if (cardNameLower.contains('nando')) {
      return Icons.restaurant_menu; // Nando's (chicken restaurant)
    }
    if (cardNameLower.contains('kfc')) {
      return Icons.fastfood; // KFC
    }
    if (cardNameLower.contains('mcdonald')) {
      return Icons.fastfood; // McDonald's
    }
    if (cardNameLower.contains('burger king')) {
      return Icons.fastfood; // Burger King
    }
    if (cardNameLower.contains('wimpy')) {
      return Icons.restaurant; // Wimpy
    }
    if (cardNameLower.contains('spur')) {
      return Icons.dining; // Spur (family restaurant)
    }
    if (cardNameLower.contains('roman')) {
      return Icons.local_pizza; // Roman's Pizza
    }
    if (cardNameLower.contains('debonairs')) {
      return Icons.local_pizza; // Debonairs Pizza
    }
    if (cardNameLower.contains('pizza hut')) {
      return Icons.local_pizza; // Pizza Hut
    }
    if (cardNameLower.contains('exclusive books')) {
      return Icons.menu_book; // Exclusive Books
    }
    if (cardNameLower.contains('cna')) {
      return Icons.book; // CNA (books/stationery)
    }
    if (cardNameLower.contains('stuttafords')) {
      return Icons.shopping_bag; // Stuttafords (department store)
    }
    if (cardNameLower.contains('incredible connection')) {
      return Icons.devices; // Incredible Connection (tech)
    }
    if (cardNameLower.contains('hi-fi corp') ||
        cardNameLower.contains('hifi corp')) {
      return Icons.speaker; // HiFi Corp (electronics)
    }
    if (cardNameLower.contains('tekkie town')) {
      return Icons.sports_soccer; // Tekkie Town (footwear)
    }
    if (cardNameLower.contains('total sports')) {
      return Icons.sports; // Total Sports
    }
    if (cardNameLower.contains('sportsmans warehouse')) {
      return Icons.sports_handball; // Sportsmans Warehouse
    }
    if (cardNameLower.contains('outdoor warehouse')) {
      return Icons.terrain; // Outdoor Warehouse
    }
    if (cardNameLower.contains('cape union mart')) {
      return Icons.hiking; // Cape Union Mart (outdoor gear)
    }

    // Generic category-based icons for unrecognized cards
    if (cardNameLower.contains('bank') || cardNameLower.contains('financial')) {
      return Icons.account_balance;
    }
    if (cardNameLower.contains('pharmacy') ||
        cardNameLower.contains('medical') ||
        cardNameLower.contains('health')) {
      return Icons.local_pharmacy;
    }
    if (cardNameLower.contains('grocery') ||
        cardNameLower.contains('supermarket') ||
        cardNameLower.contains('food')) {
      return Icons.local_grocery_store;
    }
    if (cardNameLower.contains('clothing') ||
        cardNameLower.contains('fashion') ||
        cardNameLower.contains('apparel')) {
      return Icons.checkroom;
    }
    if (cardNameLower.contains('restaurant') ||
        cardNameLower.contains('cafe') ||
        cardNameLower.contains('coffee')) {
      return Icons.restaurant;
    }
    if (cardNameLower.contains('fuel') ||
        cardNameLower.contains('petrol') ||
        cardNameLower.contains('gas')) {
      return Icons.local_gas_station;
    }
    if (cardNameLower.contains('fitness') ||
        cardNameLower.contains('gym') ||
        cardNameLower.contains('sport')) {
      return Icons.fitness_center;
    }
    if (cardNameLower.contains('electronics') ||
        cardNameLower.contains('tech') ||
        cardNameLower.contains('computer')) {
      return Icons.devices;
    }

    // Fall back to barcode type icon if no specific match found
    return _getBarcodeIcon(barcodeType);
  }

  /// Get brand-specific color for South African loyalty cards
  Color _getCardColor(String cardName, BuildContext context) {
    final cardNameLower = cardName.toLowerCase();

    // South African brand colors
    if (cardNameLower.contains('pick n pay') ||
        cardNameLower.contains('pick\'n pay') ||
        cardNameLower.contains('picknpay')) {
      return const Color(0xFF0077BE); // Pick n Pay blue
    }
    if (cardNameLower.contains('checkers')) {
      return const Color(0xFFD62E1F); // Checkers red
    }
    if (cardNameLower.contains('woolworths') ||
        cardNameLower.contains('woolies')) {
      return const Color(0xFF000000); // Woolworths black
    }
    if (cardNameLower.contains('clicks')) {
      return const Color(0xFF00A651); // Clicks green
    }
    if (cardNameLower.contains('dis-chem') ||
        cardNameLower.contains('dischem')) {
      return const Color(0xFF0066CC); // Dis-Chem blue
    }
    if (cardNameLower.contains('spar')) {
      return const Color(0xFFFF6600); // SPAR orange
    }
    if (cardNameLower.contains('makro')) {
      return const Color(0xFF003366); // Makro navy
    }
    if (cardNameLower.contains('game')) {
      return const Color(0xFF228B22); // Game green
    }
    if (cardNameLower.contains('capitec')) {
      return const Color(0xFF1E3A8A); // Capitec blue
    }
    if (cardNameLower.contains('fnb') ||
        cardNameLower.contains('first national')) {
      return const Color(0xFF006B3D); // FNB green
    }
    if (cardNameLower.contains('absa')) {
      return const Color(0xFFDC143C); // ABSA red
    }
    if (cardNameLower.contains('standard bank') ||
        cardNameLower.contains('standardbank')) {
      return const Color(0xFF004B87); // Standard Bank blue
    }
    if (cardNameLower.contains('nedbank')) {
      return const Color(0xFF00A651); // Nedbank green
    }
    if (cardNameLower.contains('discovery')) {
      return const Color(0xFF8A2BE2); // Discovery purple
    }
    if (cardNameLower.contains('virgin active')) {
      return const Color(0xFFE60026); // Virgin red
    }
    if (cardNameLower.contains('kauai')) {
      return const Color(0xFF32CD32); // Kauai green
    }
    if (cardNameLower.contains('mugg & bean') ||
        cardNameLower.contains('mugg and bean')) {
      return const Color(0xFF8B4513); // Mugg & Bean brown
    }
    if (cardNameLower.contains('vida')) {
      return const Color(0xFF2E8B57); // Vida green
    }
    if (cardNameLower.contains('steers')) {
      return const Color(0xFFFFD700); // Steers gold
    }
    if (cardNameLower.contains('nando')) {
      return const Color(0xFFFF4500); // Nando's orange
    }
    if (cardNameLower.contains('kfc')) {
      return const Color(0xFFDC143C); // KFC red
    }
    if (cardNameLower.contains('mcdonald')) {
      return const Color(0xFFFFD700); // McDonald's yellow
    }
    if (cardNameLower.contains('edgars')) {
      return const Color(0xFF9370DB); // Edgars purple
    }
    if (cardNameLower.contains('truworths')) {
      return const Color(0xFF800080); // Truworths purple
    }
    if (cardNameLower.contains('mr price') || cardNameLower.contains('mrp')) {
      return const Color(0xFF228B22); // Mr Price green
    }
    if (cardNameLower.contains('pep')) {
      return const Color(0xFFFF69B4); // PEP pink
    }
    if (cardNameLower.contains('engen') ||
        cardNameLower.contains('shell') ||
        cardNameLower.contains('bp') ||
        cardNameLower.contains('caltex')) {
      return const Color(0xFF008B8B); // Fuel station teal
    }

    // Fallback to theme color
    return Theme.of(context).colorScheme.primaryContainer;
  }

  /// Get appropriate icon color that contrasts with card background
  Color _getCardIconColor(String cardName, BuildContext context) {
    final cardNameLower = cardName.toLowerCase();

    // White icons for dark backgrounds
    if (cardNameLower.contains('woolworths') ||
        cardNameLower.contains('woolies') ||
        cardNameLower.contains('makro') ||
        cardNameLower.contains('capitec') ||
        cardNameLower.contains('standard bank') ||
        cardNameLower.contains('standardbank')) {
      return Colors.white;
    }

    // Dark icons for light backgrounds
    if (cardNameLower.contains('steers') ||
        cardNameLower.contains('mcdonald') ||
        cardNameLower.contains('spar')) {
      return Colors.black87;
    }

    // Default white for most colored backgrounds
    return Colors.white;
  }
}
