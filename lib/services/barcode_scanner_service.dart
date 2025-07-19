import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:card_keep/models/loyalty_card.dart';

class BarcodeScannerService {
  static Future<String?> scanBarcode() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color of the scan line
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );

      if (result != '-1') {
        return result;
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('Failed to scan barcode: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during barcode scanning: $e');
    }
  }

  static Future<String?> scanQRCode() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.QR,
      );

      if (result != '-1') {
        return result;
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('Failed to scan QR code: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error during QR code scanning: $e');
    }
  }

  static BarcodeType detectBarcodeType(String barcodeData) {
    // Basic barcode type detection based on length and pattern
    if (barcodeData.length == 13 && RegExp(r'^\d+$').hasMatch(barcodeData)) {
      return BarcodeType.ean13;
    } else if (barcodeData.length <= 20 &&
        RegExp(r'^[A-Z0-9\-\.\$\/\+\%]+$').hasMatch(barcodeData)) {
      return BarcodeType.code39;
    } else if (barcodeData.contains(RegExp(r'[a-z]'))) {
      return BarcodeType.code128;
    } else if (barcodeData.length > 50) {
      return BarcodeType.pdf417;
    } else {
      return BarcodeType.qrCode;
    }
  }

  static String getBarcodeTypeDisplayName(BarcodeType type) {
    switch (type) {
      case BarcodeType.code128:
        return 'Code 128';
      case BarcodeType.code39:
        return 'Code 39';
      case BarcodeType.ean13:
        return 'EAN-13';
      case BarcodeType.ean8:
        return 'EAN-8';
      case BarcodeType.upca:
        return 'UPC-A';
      case BarcodeType.upce:
        return 'UPC-E';
      case BarcodeType.qrCode:
        return 'QR Code';
      case BarcodeType.pdf417:
        return 'PDF417';
    }
  }

  static bool isValidBarcodeData(String data, BarcodeType type) {
    if (data.isEmpty) return false;

    switch (type) {
      case BarcodeType.ean13:
        return data.length == 13 && RegExp(r'^\d+$').hasMatch(data);
      case BarcodeType.ean8:
        return data.length == 8 && RegExp(r'^\d+$').hasMatch(data);
      case BarcodeType.upca:
        return data.length == 12 && RegExp(r'^\d+$').hasMatch(data);
      case BarcodeType.upce:
        return data.length == 8 && RegExp(r'^\d+$').hasMatch(data);
      case BarcodeType.code39:
        return RegExp(r'^[A-Z0-9\-\.\$\/\+\%\s]+$').hasMatch(data);
      case BarcodeType.code128:
        return data.length <= 80; // Code 128 can encode ASCII characters
      case BarcodeType.qrCode:
        return data.length <= 7000; // QR codes can store up to ~7000 characters
      case BarcodeType.pdf417:
        return data.length <= 2700; // PDF417 can store up to ~2700 characters
    }
  }
}
