import 'package:hive/hive.dart';

part 'loyalty_card.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String cardName;

  @HiveField(2)
  final String barcodeData;

  @HiveField(3)
  final BarcodeType barcodeType;

  @HiveField(4)
  final String? storeLogoUrl;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? updatedAt;

  @HiveField(7)
  final DateTime lastSyncedAt;

  @HiveField(8)
  final bool needsSync;

  LoyaltyCard({
    this.id,
    required this.cardName,
    required this.barcodeData,
    required this.barcodeType,
    this.storeLogoUrl,
    required this.createdAt,
    this.updatedAt,
    DateTime? lastSyncedAt,
    this.needsSync = true,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as int?,
      cardName: json['cardName'] as String,
      barcodeData: json['barcodeData'] as String,
      barcodeType:
          BarcodeTypeHelper.stringToEnum(json['barcodeType'] as String),
      storeLogoUrl: json['storeLogoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastSyncedAt: DateTime.now(),
      needsSync: false, // From server, so it's synced
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardName': cardName,
      'barcodeData': barcodeData,
      'barcodeType': BarcodeTypeHelper.enumToString(barcodeType),
      'storeLogoUrl': storeLogoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LoyaltyCard copyWith({
    int? id,
    String? cardName,
    String? barcodeData,
    BarcodeType? barcodeType,
    String? storeLogoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    bool? needsSync,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      barcodeData: barcodeData ?? this.barcodeData,
      barcodeType: barcodeType ?? this.barcodeType,
      storeLogoUrl: storeLogoUrl ?? this.storeLogoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Create a copy marked as needing sync
  LoyaltyCard markForSync() {
    return copyWith(
      needsSync: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Create a copy marked as synced
  LoyaltyCard markAsSynced() {
    return copyWith(
      needsSync: false,
      lastSyncedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoyaltyCard &&
        other.id == id &&
        other.cardName == cardName &&
        other.barcodeData == barcodeData &&
        other.barcodeType == barcodeType &&
        other.storeLogoUrl == storeLogoUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastSyncedAt == lastSyncedAt &&
        other.needsSync == needsSync;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      cardName,
      barcodeData,
      barcodeType,
      storeLogoUrl,
      createdAt,
      updatedAt,
      lastSyncedAt,
      needsSync,
    );
  }
}

@HiveType(typeId: 1)
enum BarcodeType {
  @HiveField(0)
  code128,
  @HiveField(1)
  code39,
  @HiveField(2)
  ean13,
  @HiveField(3)
  ean8,
  @HiveField(4)
  upca,
  @HiveField(5)
  upce,
  @HiveField(6)
  qrCode,
  @HiveField(7)
  pdf417,
}

class BarcodeTypeHelper {
  static const Map<BarcodeType, String> _enumToString = {
    BarcodeType.code128: 'code128',
    BarcodeType.code39: 'code39',
    BarcodeType.ean13: 'ean13',
    BarcodeType.ean8: 'ean8',
    BarcodeType.upca: 'upca',
    BarcodeType.upce: 'upce',
    BarcodeType.qrCode: 'qrCode',
    BarcodeType.pdf417: 'pdf417',
  };

  static const Map<String, BarcodeType> _stringToEnum = {
    'code128': BarcodeType.code128,
    'code39': BarcodeType.code39,
    'ean13': BarcodeType.ean13,
    'ean8': BarcodeType.ean8,
    'upca': BarcodeType.upca,
    'upce': BarcodeType.upce,
    'qrcode': BarcodeType.qrCode,
    'qrCode': BarcodeType.qrCode,
    'pdf417': BarcodeType.pdf417,
  };

  static String enumToString(BarcodeType type) {
    return _enumToString[type] ?? 'code128';
  }

  static BarcodeType stringToEnum(String value) {
    return _stringToEnum[value.toLowerCase()] ?? BarcodeType.code128;
  }
}
