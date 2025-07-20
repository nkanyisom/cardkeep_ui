import 'package:flutter/material.dart';
import '../models/loyalty_card.dart';

/// Recognized South African loyalty card information
class SACard {
  final String brandName;
  final String displayName;
  final IconData icon;
  final Color brandColor;
  final Color iconColor;
  final List<String> barcodePatterns;
  final List<int> barcodeLengths;

  const SACard({
    required this.brandName,
    required this.displayName,
    required this.icon,
    required this.brandColor,
    required this.iconColor,
    required this.barcodePatterns,
    required this.barcodeLengths,
  });
}

/// Result of SA card recognition
class SACardRecognitionResult {
  final bool isRecognized;
  final SACard? card;
  final double confidence;
  final String cardNumber;

  const SACardRecognitionResult({
    required this.isRecognized,
    required this.card,
    required this.confidence,
    required this.cardNumber,
  });
}

/// Service for recognizing South African loyalty cards from barcode patterns
class SACardRecognitionService {
  /// Database of South African loyalty cards with their barcode patterns
  static final Map<String, SACard> _saCards = {
    // Major Grocery Stores
    'pick_n_pay': SACard(
      brandName: 'pick_n_pay',
      displayName: 'Pick n Pay',
      icon: Icons.shopping_cart,
      brandColor: Color(0xFF0077BE),
      iconColor: Colors.white,
      barcodePatterns: ['60', '600', '6001', '60011'],
      barcodeLengths: [13, 12, 10],
    ),
    'checkers': SACard(
      brandName: 'checkers',
      displayName: 'Checkers',
      icon: Icons.local_grocery_store,
      brandColor: Color(0xFFD62E1F),
      iconColor: Colors.white,
      barcodePatterns: ['71', '711', '7110', '71101'],
      barcodeLengths: [13, 12],
    ),
    'woolworths': SACard(
      brandName: 'woolworths',
      displayName: 'Woolworths',
      icon: Icons.store,
      brandColor: Color(0xFF000000),
      iconColor: Colors.white,
      barcodePatterns: ['60', '601', '6012', '60123'],
      barcodeLengths: [13, 12, 11],
    ),
    'spar': SACard(
      brandName: 'spar',
      displayName: 'SPAR',
      icon: Icons.shopping_basket,
      brandColor: Color(0xFFFF6600),
      iconColor: Colors.black87,
      barcodePatterns: ['60', '602', '6020'],
      barcodeLengths: [13, 12],
    ),
    'makro': SACard(
      brandName: 'makro',
      displayName: 'Makro',
      icon: Icons.warehouse,
      brandColor: Color(0xFF003366),
      iconColor: Colors.white,
      barcodePatterns: ['60', '605', '6051'],
      barcodeLengths: [13, 12],
    ),

    // Pharmacies & Health
    'clicks': SACard(
      brandName: 'clicks',
      displayName: 'Clicks',
      icon: Icons.local_pharmacy,
      brandColor: Color(0xFF00A651),
      iconColor: Colors.white,
      barcodePatterns: ['60', '603', '6030'],
      barcodeLengths: [13, 12, 10],
    ),
    'dischem': SACard(
      brandName: 'dischem',
      displayName: 'Dis-Chem',
      icon: Icons.medical_services,
      brandColor: Color(0xFF0066CC),
      iconColor: Colors.white,
      barcodePatterns: ['60', '604', '6040'],
      barcodeLengths: [13, 12],
    ),

    // Retail & Fashion
    'edgars': SACard(
      brandName: 'edgars',
      displayName: 'Edgars',
      icon: Icons.checkroom,
      brandColor: Color(0xFF9370DB),
      iconColor: Colors.white,
      barcodePatterns: ['60', '607', '6071'],
      barcodeLengths: [13, 12, 11],
    ),
    'truworths': SACard(
      brandName: 'truworths',
      displayName: 'Truworths',
      icon: Icons.style,
      brandColor: Color(0xFF800080),
      iconColor: Colors.white,
      barcodePatterns: ['60', '608', '6081'],
      barcodeLengths: [13, 12],
    ),
    'mr_price': SACard(
      brandName: 'mr_price',
      displayName: 'Mr Price',
      icon: Icons.shopping_bag,
      brandColor: Color(0xFF228B22),
      iconColor: Colors.white,
      barcodePatterns: ['60', '609', '6091'],
      barcodeLengths: [13, 12],
    ),
    'foschini': SACard(
      brandName: 'foschini',
      displayName: 'Foschini',
      icon: Icons.local_mall,
      brandColor: Color(0xFF4B0082),
      iconColor: Colors.white,
      barcodePatterns: ['60', '606', '6061'],
      barcodeLengths: [13, 12],
    ),
    'ackermans': SACard(
      brandName: 'ackermans',
      displayName: 'Ackermans',
      icon: Icons.family_restroom,
      brandColor: Color(0xFF1E90FF),
      iconColor: Colors.white,
      barcodePatterns: ['60', '610', '6101'],
      barcodeLengths: [13, 12],
    ),
    'pep': SACard(
      brandName: 'pep',
      displayName: 'PEP',
      icon: Icons.child_friendly,
      brandColor: Color(0xFFFF69B4),
      iconColor: Colors.black87,
      barcodePatterns: ['60', '611', '6111'],
      barcodeLengths: [13, 12],
    ),

    // Electronics & Tech
    'game': SACard(
      brandName: 'game',
      displayName: 'Game',
      icon: Icons.sports_esports,
      brandColor: Color(0xFF228B22),
      iconColor: Colors.white,
      barcodePatterns: ['60', '615', '6151'],
      barcodeLengths: [13, 12],
    ),
    'incredible_connection': SACard(
      brandName: 'incredible_connection',
      displayName: 'Incredible Connection',
      icon: Icons.devices,
      brandColor: Color(0xFF1E90FF),
      iconColor: Colors.white,
      barcodePatterns: ['60', '620', '6201'],
      barcodeLengths: [13, 12],
    ),
    'hifi_corp': SACard(
      brandName: 'hifi_corp',
      displayName: 'HiFi Corp',
      icon: Icons.speaker,
      brandColor: Color(0xFF2E8B57),
      iconColor: Colors.white,
      barcodePatterns: ['60', '621', '6211'],
      barcodeLengths: [13, 12],
    ),

    // Banks & Financial
    'capitec': SACard(
      brandName: 'capitec',
      displayName: 'Capitec Bank',
      icon: Icons.account_balance,
      brandColor: Color(0xFF1E3A8A),
      iconColor: Colors.white,
      barcodePatterns: ['50', '501', '5011'],
      barcodeLengths: [16, 15, 13],
    ),
    'fnb': SACard(
      brandName: 'fnb',
      displayName: 'FNB',
      icon: Icons.account_balance,
      brandColor: Color(0xFF006B3D),
      iconColor: Colors.white,
      barcodePatterns: ['50', '502', '5021'],
      barcodeLengths: [16, 15, 13],
    ),
    'absa': SACard(
      brandName: 'absa',
      displayName: 'ABSA',
      icon: Icons.account_balance,
      brandColor: Color(0xFFDC143C),
      iconColor: Colors.white,
      barcodePatterns: ['50', '503', '5031'],
      barcodeLengths: [16, 15, 13],
    ),
    'standard_bank': SACard(
      brandName: 'standard_bank',
      displayName: 'Standard Bank',
      icon: Icons.account_balance,
      brandColor: Color(0xFF004B87),
      iconColor: Colors.white,
      barcodePatterns: ['50', '504', '5041'],
      barcodeLengths: [16, 15, 13],
    ),
    'nedbank': SACard(
      brandName: 'nedbank',
      displayName: 'Nedbank',
      icon: Icons.account_balance,
      brandColor: Color(0xFF00A651),
      iconColor: Colors.white,
      barcodePatterns: ['50', '505', '5051'],
      barcodeLengths: [16, 15, 13],
    ),

    // Fuel Stations
    'engen': SACard(
      brandName: 'engen',
      displayName: 'Engen',
      icon: Icons.local_gas_station,
      brandColor: Color(0xFF008B8B),
      iconColor: Colors.white,
      barcodePatterns: ['70', '701', '7011'],
      barcodeLengths: [13, 12, 10],
    ),
    'shell': SACard(
      brandName: 'shell',
      displayName: 'Shell',
      icon: Icons.local_gas_station,
      brandColor: Color(0xFFFFD700),
      iconColor: Colors.black87,
      barcodePatterns: ['70', '702', '7021'],
      barcodeLengths: [13, 12, 10],
    ),
    'bp': SACard(
      brandName: 'bp',
      displayName: 'BP',
      icon: Icons.local_gas_station,
      brandColor: Color(0xFF228B22),
      iconColor: Colors.white,
      barcodePatterns: ['70', '703', '7031'],
      barcodeLengths: [13, 12, 10],
    ),
    'caltex': SACard(
      brandName: 'caltex',
      displayName: 'Caltex',
      icon: Icons.local_gas_station,
      brandColor: Color(0xFFDC143C),
      iconColor: Colors.white,
      barcodePatterns: ['70', '704', '7041'],
      barcodeLengths: [13, 12, 10],
    ),

    // Fitness & Health
    'virgin_active': SACard(
      brandName: 'virgin_active',
      displayName: 'Virgin Active',
      icon: Icons.fitness_center,
      brandColor: Color(0xFFE60026),
      iconColor: Colors.white,
      barcodePatterns: ['80', '801', '8011'],
      barcodeLengths: [12, 10, 8],
    ),
    'planet_fitness': SACard(
      brandName: 'planet_fitness',
      displayName: 'Planet Fitness',
      icon: Icons.sports_gymnastics,
      brandColor: Color(0xFF800080),
      iconColor: Colors.white,
      barcodePatterns: ['80', '802', '8021'],
      barcodeLengths: [12, 10, 8],
    ),

    // Restaurants & Food
    'steers': SACard(
      brandName: 'steers',
      displayName: 'Steers',
      icon: Icons.fastfood,
      brandColor: Color(0xFFFFD700),
      iconColor: Colors.black87,
      barcodePatterns: ['90', '901', '9011'],
      barcodeLengths: [12, 10],
    ),
    'nandos': SACard(
      brandName: 'nandos',
      displayName: "Nando's",
      icon: Icons.restaurant_menu,
      brandColor: Color(0xFFFF4500),
      iconColor: Colors.white,
      barcodePatterns: ['90', '902', '9021'],
      barcodeLengths: [12, 10],
    ),
    'mugg_bean': SACard(
      brandName: 'mugg_bean',
      displayName: 'Mugg & Bean',
      icon: Icons.local_cafe,
      brandColor: Color(0xFF8B4513),
      iconColor: Colors.white,
      barcodePatterns: ['90', '903', '9031'],
      barcodeLengths: [12, 10],
    ),
  };

  /// Recognize a South African loyalty card from barcode data
  static SACardRecognitionResult recognizeCard(String barcodeData) {
    // Clean the barcode data
    final cleanBarcode = barcodeData.trim();
    final barcodeLength = cleanBarcode.length;

    // Check each SA card pattern
    for (final entry in _saCards.entries) {
      final card = entry.value;

      // Check if barcode length matches expected lengths
      if (!card.barcodeLengths.contains(barcodeLength)) {
        continue;
      }

      // Check if barcode starts with any of the card's patterns
      for (final pattern in card.barcodePatterns) {
        if (cleanBarcode.startsWith(pattern)) {
          return SACardRecognitionResult(
            isRecognized: true,
            card: card,
            confidence:
                _calculateConfidence(cleanBarcode, pattern, barcodeLength),
            cardNumber: _extractCardNumber(cleanBarcode, pattern),
          );
        }
      }
    }

    // No SA card recognized
    return SACardRecognitionResult(
      isRecognized: false,
      card: null,
      confidence: 0.0,
      cardNumber: cleanBarcode,
    );
  }

  /// Calculate recognition confidence based on pattern match
  static double _calculateConfidence(
      String barcode, String pattern, int length) {
    double confidence = 0.7; // Base confidence for pattern match

    // Increase confidence for longer pattern matches
    confidence += (pattern.length / 4.0) * 0.2;

    // Increase confidence for standard barcode lengths
    if ([10, 12, 13, 16].contains(length)) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Extract card number (remove pattern prefix if needed)
  static String _extractCardNumber(String barcode, String pattern) {
    // For display purposes, show the full barcode
    // You can customize this logic based on specific card requirements
    return barcode;
  }

  /// Get all available SA cards for Quick Add functionality
  static List<SACard> getAllSACards() {
    return _saCards.values.toList();
  }

  /// Get popular SA cards for Quick Add
  static List<SACard> getPopularSACards() {
    final popularKeys = [
      'pick_n_pay',
      'checkers',
      'woolworths',
      'clicks',
      'dischem',
      'spar',
      'game',
      'edgars',
      'capitec',
      'fnb',
      'engen',
      'shell'
    ];

    return popularKeys
        .where((key) => _saCards.containsKey(key))
        .map((key) => _saCards[key]!)
        .toList();
  }

  /// Create a loyalty card from recognition result
  static LoyaltyCard createLoyaltyCard({
    required SACardRecognitionResult result,
    required String barcodeData,
    required BarcodeType barcodeType,
    String? customName,
  }) {
    final displayName = customName ??
        (result.isRecognized ? result.card!.displayName : 'Loyalty Card');

    return LoyaltyCard(
      cardName: displayName,
      barcodeData: barcodeData,
      barcodeType: barcodeType,
      needsSync: true,
      createdAt: DateTime.now(),
    );
  }

  /// Get barcode type suggestion based on SA card
  static BarcodeType suggestBarcodeType(SACard? card) {
    if (card == null) return BarcodeType.code128;

    // Banks typically use Code 128
    if (card.brandName.contains('bank') ||
        ['capitec', 'fnb', 'absa', 'standard_bank', 'nedbank']
            .contains(card.brandName)) {
      return BarcodeType.code128;
    }

    // Most retail cards use EAN-13
    return BarcodeType.ean13;
  }
}
