import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    as mlkit;
import 'package:card_keep/models/loyalty_card.dart' as models;

class AdvancedBarcodeScannerService {
  static CameraController? _cameraController;
  static List<CameraDescription>? _cameras;
  static mlkit.BarcodeScanner? _barcodeScanner;

  // Initialize cameras
  static Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
      _barcodeScanner = mlkit.BarcodeScanner();
    } catch (e) {
      throw Exception('Failed to initialize cameras: $e');
    }
  }

  // Initialize camera controller
  static Future<CameraController> initializeCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) {
      await initializeCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    // Use the first back camera available
    final camera = _cameras!.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();
    return _cameraController!;
  }

  // Scan barcode from camera image
  static Future<List<mlkit.Barcode>> scanBarcodeFromImage(
      CameraImage image) async {
    try {
      if (_barcodeScanner == null) {
        _barcodeScanner = mlkit.BarcodeScanner();
      }

      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return [];

      final barcodes = await _barcodeScanner!.processImage(inputImage);
      return barcodes;
    } catch (e) {
      print('Error scanning barcode: $e');
      return [];
    }
  }

  // Convert CameraImage to InputImage for ML Kit
  static mlkit.InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;

    final camera = _cameraController!.description;
    final rotation =
        mlkit.InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final format = mlkit.InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    if (image.planes.isEmpty) return null;
    final plane = image.planes.first;

    return mlkit.InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: mlkit.InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // Convert ML Kit BarcodeType to our BarcodeType enum
  static models.BarcodeType convertBarcodeType(mlkit.BarcodeType mlkitType) {
    // Convert ML Kit barcode type to our custom enum
    // We'll use the type index and string representation as fallback
    try {
      switch (mlkitType.index) {
        case 1: // EAN-13
          return models.BarcodeType.ean13;
        case 2: // EAN-8
          return models.BarcodeType.ean8;
        case 3: // UPC-A
          return models.BarcodeType.upca;
        case 4: // UPC-E
          return models.BarcodeType.upce;
        case 7: // Code 128
          return models.BarcodeType.code128;
        case 8: // Code 39
          return models.BarcodeType.code39;
        case 512: // QR Code (most common)
          return models.BarcodeType.qrCode;
        default:
          // For any unrecognized types, default to QR Code
          return models.BarcodeType.qrCode;
      }
    } catch (e) {
      // If there's any issue with the conversion, default to QR Code
      return models.BarcodeType.qrCode;
    }
  }

  // Get barcode type display name
  static String getBarcodeTypeDisplayName(models.BarcodeType type) {
    switch (type) {
      case models.BarcodeType.ean13:
        return 'EAN-13';
      case models.BarcodeType.ean8:
        return 'EAN-8';
      case models.BarcodeType.upca:
        return 'UPC-A';
      case models.BarcodeType.upce:
        return 'UPC-E';
      case models.BarcodeType.code128:
        return 'Code 128';
      case models.BarcodeType.code39:
        return 'Code 39';
      case models.BarcodeType.qrCode:
        return 'QR Code';
      case models.BarcodeType.pdf417:
        return 'PDF417';
    }
  }

  // Dispose resources
  static Future<void> dispose() async {
    await _cameraController?.dispose();
    await _barcodeScanner?.close();
    _cameraController = null;
    _barcodeScanner = null;
  }

  // Simple barcode scanner using flutter_barcode_scanner (fallback)
  static Future<String?> scanBarcodeSimple() async {
    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Scanner line color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );

      if (result != '-1') {
        return result;
      }
      return null;
    } on PlatformException {
      return null;
    }
  }
}
