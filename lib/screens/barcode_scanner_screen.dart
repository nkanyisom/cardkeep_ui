import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/advanced_barcode_scanner_service.dart';
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

      _cameraController =
          await AdvancedBarcodeScannerService.initializeCameraController();

      if (mounted) {
        setState(() => _isLoading = false);
        _startScanning();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog('Camera initialization failed: $e');
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
        setState(() {
          _scannedBarcode = barcode.rawValue;
          _selectedBarcodeType =
              AdvancedBarcodeScannerService.convertBarcodeType(barcode.type);
          _isScanning = false;
        });

        // Stop image stream after successful scan
        await _cameraController!.stopImageStream();

        // Show success feedback
        _showScanSuccessDialog();
      }
    });
  }

  void _showScanSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Scanned!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barcode: $_scannedBarcode'),
            const SizedBox(height: 8),
            Text(
                'Type: ${AdvancedBarcodeScannerService.getBarcodeTypeDisplayName(_selectedBarcodeType)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _rescan();
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCardForm();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showCardForm() {
    setState(() => _isScanning = false);
  }

  void _rescan() {
    setState(() {
      _scannedBarcode = null;
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
          _isScanning = false;
        });
        _showCardForm();
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              // Camera preview
              SizedBox.expand(
                child: CameraPreview(_cameraController!),
              ),
              // Scanning overlay
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: const Center(
                  child: Text(
                    'Position barcode within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Scanning indicator
              if (_isScanning)
                const Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      color: Colors.black54,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Scanning...',
                          style: TextStyle(color: Colors.white),
                        ),
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
            child: Column(
              children: [
                const Text(
                  'Point your camera at a barcode or QR code',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _useSimpleScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Simple Scanner'),
                    ),
                    ElevatedButton.icon(
                      onPressed: _rescan,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Restart'),
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
}
