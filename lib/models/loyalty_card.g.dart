// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoyaltyCardAdapter extends TypeAdapter<LoyaltyCard> {
  @override
  final int typeId = 0;

  @override
  LoyaltyCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoyaltyCard(
      id: fields[0] as int?,
      cardName: fields[1] as String,
      barcodeData: fields[2] as String,
      barcodeType: fields[3] as BarcodeType,
      storeLogoUrl: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
      lastSyncedAt: fields[7] as DateTime?,
      needsSync: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, LoyaltyCard obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.cardName)
      ..writeByte(2)
      ..write(obj.barcodeData)
      ..writeByte(3)
      ..write(obj.barcodeType)
      ..writeByte(4)
      ..write(obj.storeLogoUrl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.lastSyncedAt)
      ..writeByte(8)
      ..write(obj.needsSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoyaltyCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BarcodeTypeAdapter extends TypeAdapter<BarcodeType> {
  @override
  final int typeId = 1;

  @override
  BarcodeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BarcodeType.code128;
      case 1:
        return BarcodeType.code39;
      case 2:
        return BarcodeType.ean13;
      case 3:
        return BarcodeType.ean8;
      case 4:
        return BarcodeType.upca;
      case 5:
        return BarcodeType.upce;
      case 6:
        return BarcodeType.qrCode;
      case 7:
        return BarcodeType.pdf417;
      default:
        return BarcodeType.code128;
    }
  }

  @override
  void write(BinaryWriter writer, BarcodeType obj) {
    switch (obj) {
      case BarcodeType.code128:
        writer.writeByte(0);
        break;
      case BarcodeType.code39:
        writer.writeByte(1);
        break;
      case BarcodeType.ean13:
        writer.writeByte(2);
        break;
      case BarcodeType.ean8:
        writer.writeByte(3);
        break;
      case BarcodeType.upca:
        writer.writeByte(4);
        break;
      case BarcodeType.upce:
        writer.writeByte(5);
        break;
      case BarcodeType.qrCode:
        writer.writeByte(6);
        break;
      case BarcodeType.pdf417:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BarcodeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
