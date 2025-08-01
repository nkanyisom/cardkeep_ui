import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/advanced_barcode_scanner_service.dart';
import 'package:card_keep/services/sa_card_recognition_service.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/widgets/custom_text_field.dart';
import 'package:card_keep/widgets/custom_button.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();

  CameraController? _cameraController;
  bool _isScanning = true;
  bool _isLoading = false;
  String? _scannedBarcode;
  BarcodeType _selectedBarcodeType = BarcodeType.qrCode;
  SACardRecognitionResult? _recognitionResult;
  StreamSubscription? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _cameraController?.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() => _isLoading = true);

      // On web, skip camera initialization and show manual input
      if (kIsWeb) {
        setState(() {
          _isLoading = false;
          _isScanning = false;
        });
        _showWebManualInputDialog();
        return;
      }

      // Try to initialize camera for mobile platforms
      _cameraController =
          await AdvancedBarcodeScannerService.initializeCameraController();

      if (mounted) {
        setState(() => _isLoading = false);
        _startScanning();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isScanning = false;
        });
        // Show manual input dialog as fallback
        _showManualInputFallback();
      }
    }
  }

  void _startScanning() {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    _cameraController!.startImageStream((CameraImage image) async {
      if (!_isScanning) return;

      final barcodes =
          await AdvancedBarcodeScannerService.scanBarcodeFromImage(image);

      if (barcodes.isNotEmpty && mounted) {
        final barcode = barcodes.first;
        final barcodeData = barcode.rawValue ?? '';

        setState(() {
          _scannedBarcode = barcodeData;
          _selectedBarcodeType =
              AdvancedBarcodeScannerService.convertBarcodeType(barcode.type);

          // Recognize South African loyalty card
          _recognitionResult =
              SACardRecognitionService.recognizeCard(barcodeData);

          // Auto-suggest barcode type based on recognized card
          if (_recognitionResult!.isRecognized) {
            _selectedBarcodeType = SACardRecognitionService.suggestBarcodeType(
                _recognitionResult!.card);
          }

          _isScanning = false;
        });

        // Stop image stream after successful scan
        await _cameraController!.stopImageStream();

        // Show intelligent scan result dialog
        _showIntelligentScanDialog();
      }
    });
  }

  void _showIntelligentScanDialog() {
    final recognition = _recognitionResult!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              recognition.isRecognized ? Icons.verified : Icons.qr_code,
              color: recognition.isRecognized ? Colors.green : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recognition.isRecognized
                    ? 'SA Card Detected!'
                    : 'Barcode Scanned',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: recognition.isRecognized ? Colors.green[700] : null,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recognition.isRecognized) ...[
              // Show recognized SA card with brand styling
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: recognition.card!.brandColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: recognition.card!.brandColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      recognition.card!.icon,
                      size: 32,
                      color: recognition.card!.iconColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recognition.card!.displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: recognition.card!.iconColor,
                            ),
                          ),
                          Text(
                            'Loyalty Card',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  recognition.card!.iconColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Card Number',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recognition.cardNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence: ${(recognition.confidence * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Type: ${_selectedBarcodeType.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Show generic barcode info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Barcode Data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scannedBarcode ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Barcode Type: ${AdvancedBarcodeScannerService.getBarcodeTypeDisplayName(_selectedBarcodeType)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _rescan();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, size: 18),
                const SizedBox(width: 4),
                Text('Scan Again'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (recognition.isRecognized) {
                _addRecognizedCard();
              } else {
                _showCardForm();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  recognition.isRecognized ? Icons.add_card : Icons.edit,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(recognition.isRecognized ? 'Add Card' : 'Continue'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Add recognized SA card automatically with smart defaults
  Future<void> _addRecognizedCard() async {
    if (_recognitionResult == null || !_recognitionResult!.isRecognized) return;

    try {
      setState(() => _isLoading = true);

      // Create loyalty card with recognized SA card data
      final loyaltyCard = SACardRecognitionService.createLoyaltyCard(
        result: _recognitionResult!,
        barcodeData: _scannedBarcode!,
        barcodeType: _selectedBarcodeType,
      );

      // Add the card using the card service
      final cardService = Provider.of<CardService>(context, listen: false);
      await cardService.addCard(loyaltyCard);

      if (mounted) {
        setState(() => _isLoading = false);

        // Show success message with card details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  _recognitionResult!.card!.icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_recognitionResult!.card!.displayName} card added successfully!',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: _recognitionResult!.card!.brandColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Navigate back to cards list
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Failed to add card: $e');
    }
  }

  void _showCardForm() {
    setState(() => _isScanning = false);
  }

  void _rescan() {
    setState(() {
      _scannedBarcode = null;
      _recognitionResult = null;
      _isScanning = true;
    });
    _startScanning();
  }

  Future<void> _useSimpleScanner() async {
    try {
      setState(() => _isLoading = true);

      final result = await AdvancedBarcodeScannerService.scanBarcodeSimple();

      setState(() => _isLoading = false);

      if (result != null) {
        setState(() {
          _scannedBarcode = result;
          _selectedBarcodeType =
              BarcodeType.qrCode; // Default for simple scanner

          // Recognize SA card from simple scanner result
          _recognitionResult = SACardRecognitionService.recognizeCard(result);

          // Auto-suggest barcode type based on recognized card
          if (_recognitionResult!.isRecognized) {
            _selectedBarcodeType = SACardRecognitionService.suggestBarcodeType(
                _recognitionResult!.card);
          }

          _isScanning = false;
        });

        // Show intelligent result dialog
        _showIntelligentScanDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Scanner failed: $e');
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate() || _scannedBarcode == null) return;

    try {
      setState(() => _isLoading = true);

      final card = LoyaltyCard(
        cardName: _cardNameController.text.trim(),
        barcodeData: _scannedBarcode!,
        barcodeType: _selectedBarcodeType,
        createdAt: DateTime.now(),
      );

      final cardService = context.read<CardService>();
      await cardService.addCard(card, context: context);

      if (mounted) {
        Navigator.of(context).pop(true); // Return success to previous screen
        // Success snackbar is now handled by ApiService
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Failed to save card: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Loyalty Card'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scannedBarcode == null
              ? _buildScannerView()
              : _buildCardForm(),
    );
  }

  Widget _buildScannerView() {
    // Check if we have a working camera controller
    bool hasCameraAccess =
        _cameraController != null && _cameraController!.value.isInitialized;

    if (!hasCameraAccess) {
      // Web-friendly interface when camera is not available
      return _buildWebFriendlyScannerView();
    }

    // Original camera view for mobile/desktop
    return _buildCameraScannerView();
  }

  Widget _buildWebFriendlyScannerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Header with web info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.web,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Web Scanner Ready',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Smart SA Card Detection Active',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Barcode scanner illustration
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to Scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Main scan button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _useSimpleScanner,
              icon: const Icon(Icons.camera_alt, size: 24),
              label: const Text(
                'Scan Barcode',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // OR divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[400])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[400])),
            ],
          ),

          const SizedBox(height: 16),

          // Manual entry button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _scannedBarcode = ''; // Trigger manual entry mode
                  _recognitionResult =
                      SACardRecognitionService.recognizeCard('');
                });
              },
              icon: const Icon(Icons.edit, size: 20),
              label: const Text(
                'Enter Manually',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Features info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.verified, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Smart Detection Features',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automatically detects 40+ South African loyalty cards',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.palette, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Applies authentic brand colors and icons',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.flash_on, color: Colors.yellow[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'One-click card addition for recognized brands',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScannerView() {
    return Column(
      children: [
        // Header with SA card detection info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.verified, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Smart SA Card Detection Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(Icons.flag, color: Colors.orange[300], size: 18),
            ],
          ),
        ),

        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Camera preview
              SizedBox.expand(
                child: CameraPreview(_cameraController!),
              ),

              // Modern scanning frame
              Center(
                child: Container(
                  width: 280,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isScanning ? Colors.green : Colors.white,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_isScanning ? Colors.green : Colors.white)
                            .withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              left: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.green, width: 4),
                              right: BorderSide(color: Colors.green, width: 4),
                            ),
                          ),
                        ),
                      ),

                      // Center instruction
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Position barcode here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scanning status indicator
              if (_isScanning)
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scanning for SA Cards...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Automatically detects South African loyalty cards',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _useSimpleScanner,
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text('Simple Scanner'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _rescan,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Restart'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanned barcode preview
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Barcode',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data: $_scannedBarcode',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${AdvancedBarcodeScannerService.getBarcodeTypeDisplayName(_selectedBarcodeType)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card name field
            CustomTextField(
              controller: _cardNameController,
              labelText: 'Card Name',
              hintText: 'e.g., Woolworths, Checkers, Pick n Pay',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a card name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Barcode type selector
            DropdownButtonFormField<BarcodeType>(
              value: _selectedBarcodeType,
              decoration: const InputDecoration(
                labelText: 'Barcode Type',
                border: OutlineInputBorder(),
              ),
              items: BarcodeType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                      AdvancedBarcodeScannerService.getBarcodeTypeDisplayName(
                          type)),
                );
              }).toList(),
              onChanged: (BarcodeType? newValue) {
                if (newValue != null) {
                  setState(() => _selectedBarcodeType = newValue);
                }
              },
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rescan,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan Again'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: _saveCard,
                    text: 'Save Card',
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Web-specific manual input dialog
  void _showWebManualInputDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.web, color: Colors.blue[600]),
            const SizedBox(width: 12),
            const Text('Web Scanner'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Camera not available on web',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter your barcode number manually or use a mobile device for camera scanning.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Enter Barcode Number',
                hintText: 'e.g., 1234567890123',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _scannedBarcode = value;
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Navigator.of(context).pop();
                  _processManualBarcode(value);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_scannedBarcode?.isNotEmpty == true) {
                Navigator.of(context).pop();
                _processManualBarcode(_scannedBarcode!);
              }
            },
            child: const Text('Process Barcode'),
          ),
        ],
      ),
    );
  }

  // Fallback manual input for any platform
  void _showManualInputFallback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Camera scanning is not available. Would you like to enter the barcode manually?'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Barcode Number',
                hintText: 'Enter barcode manually',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _scannedBarcode = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_scannedBarcode?.isNotEmpty == true) {
                Navigator.of(context).pop();
                _processManualBarcode(_scannedBarcode!);
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  // Process manually entered barcode
  void _processManualBarcode(String barcodeData) {
    setState(() {
      _scannedBarcode = barcodeData;
      _selectedBarcodeType = BarcodeType.qrCode; // Default type

      // Recognize South African loyalty card
      _recognitionResult = SACardRecognitionService.recognizeCard(barcodeData);

      // Auto-suggest barcode type based on recognized card
      if (_recognitionResult!.isRecognized) {
        _selectedBarcodeType = SACardRecognitionService.suggestBarcodeType(
            _recognitionResult!.card);
      }

      _isScanning = false;
    });

    // Show intelligent scan result dialog
    _showIntelligentScanDialog();
  }
}
