import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/card_service.dart';
import 'package:card_keep/services/barcode_scanner_service.dart';
import 'package:card_keep/screens/barcode_scanner_screen.dart';
import 'package:card_keep/widgets/custom_text_field.dart';
import 'package:card_keep/widgets/custom_button.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _barcodeDataController = TextEditingController();
  final _storeLogoUrlController = TextEditingController();

  BarcodeType _selectedBarcodeType = BarcodeType.code128;
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNameController.dispose();
    _barcodeDataController.dispose();
    _storeLogoUrlController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    try {
      final scannedData = await BarcodeScannerService.scanBarcode();
      if (scannedData != null && mounted) {
        setState(() {
          _barcodeDataController.text = scannedData;
          _selectedBarcodeType =
              BarcodeScannerService.detectBarcodeType(scannedData);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanning failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openAdvancedScanner() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );

    // If a card was saved successfully, go back to the previous screen
    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final card = LoyaltyCard(
        cardName: _cardNameController.text.trim(),
        barcodeData: _barcodeDataController.text.trim(),
        barcodeType: _selectedBarcodeType,
        storeLogoUrl: _storeLogoUrlController.text.trim().isEmpty
            ? null
            : _storeLogoUrlController.text.trim(),
        createdAt: DateTime.now(),
      );

      final success = await context.read<CardService>().addCard(
            card,
            context: context,
          );

      if (success && mounted) {
        Navigator.pop(context);
        // Success snackbar is now handled by ApiService
      } else if (mounted) {
        final errorMessage = context.read<CardService>().errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to add card'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Loyalty Card'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Name Field
              CustomTextField(
                controller: _cardNameController,
                labelText: 'Card Name',
                hintText: 'e.g., Starbucks Rewards',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a card name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Barcode Data Field with Scan Button
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _barcodeDataController,
                      labelText: 'Barcode Data',
                      hintText: 'Enter or scan barcode',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter barcode data';
                        }
                        if (!BarcodeScannerService.isValidBarcodeData(
                            value.trim(), _selectedBarcodeType)) {
                          return 'Invalid barcode data for selected type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.qr_code_scanner),
                    tooltip: 'Scan Options',
                    onSelected: (value) {
                      if (value == 'simple') {
                        _scanBarcode();
                      } else if (value == 'advanced') {
                        _openAdvancedScanner();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'simple',
                        child: ListTile(
                          leading: Icon(Icons.camera_alt),
                          title: Text('Simple Scanner'),
                          subtitle: Text('Quick barcode scan'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'advanced',
                        child: ListTile(
                          leading: Icon(Icons.camera_enhance),
                          title: Text('Advanced Scanner'),
                          subtitle: Text('Camera preview + ML Kit'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Barcode Type Dropdown
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
                        BarcodeScannerService.getBarcodeTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedBarcodeType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Store Logo URL Field (Optional)
              CustomTextField(
                controller: _storeLogoUrlController,
                labelText: 'Store Logo URL (Optional)',
                hintText: 'https://example.com/logo.png',
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                onPressed: _isLoading ? null : _saveCard,
                text: 'Save Card',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
