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

              // Quick Add South African Cards Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Add South African Cards',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPresetChip('Pick n Pay Smart Shopper'),
                          _buildPresetChip('Checkers Xtra Savings'),
                          _buildPresetChip('Woolworths WRewards'),
                          _buildPresetChip('Clicks ClubCard'),
                          _buildPresetChip('Dis-Chem Benefit'),
                          _buildPresetChip('SPAR Rewards'),
                          _buildPresetChip('Capitec'),
                          _buildPresetChip('FNB eBucks'),
                          _buildPresetChip('Discovery Vitality'),
                          _buildPresetChip('Virgin Active'),
                          _buildPresetChip('Mugg & Bean'),
                          _buildPresetChip('Steers'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Barcode Data Field
              CustomTextField(
                controller: _barcodeDataController,
                labelText: 'Barcode Data',
                hintText: 'Enter barcode data or scan using camera',
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
              const SizedBox(height: 16),

              // Scan Options Card - Web-Friendly
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scan Barcode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Use your camera to scan loyalty card barcodes. Supports automatic detection of South African loyalty cards.',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _scanBarcode,
                              icon: const Icon(Icons.camera_alt, size: 18),
                              label: const Text('Quick Scan'),
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openAdvancedScanner,
                              icon: const Icon(Icons.camera_enhance, size: 18),
                              label: const Text('Smart Scanner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Basic scanning',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Auto-detect SA cards',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

  Widget _buildPresetChip(String cardName) {
    return ActionChip(
      label: Text(cardName),
      onPressed: () {
        setState(() {
          _cardNameController.text = cardName;
          // Generate a sample barcode for demo purposes
          _barcodeDataController.text = _generateSampleBarcode(cardName);
          _selectedBarcodeType = BarcodeType.code128;
        });
      },
    );
  }

  String _generateSampleBarcode(String cardName) {
    // Generate sample barcodes based on card name
    final cardNameLower = cardName.toLowerCase();

    if (cardNameLower.contains('pick n pay')) {
      return '1234567890123';
    }
    if (cardNameLower.contains('checkers')) {
      return '2345678901234';
    }
    if (cardNameLower.contains('woolworths')) {
      return '3456789012345';
    }
    if (cardNameLower.contains('clicks')) {
      return '4567890123456';
    }
    if (cardNameLower.contains('dis-chem')) {
      return '5678901234567';
    }
    if (cardNameLower.contains('spar')) {
      return '6789012345678';
    }
    if (cardNameLower.contains('capitec')) {
      return '7890123456789';
    }
    if (cardNameLower.contains('fnb')) {
      return '8901234567890';
    }
    if (cardNameLower.contains('discovery')) {
      return '9012345678901';
    }
    if (cardNameLower.contains('virgin')) {
      return '0123456789012';
    }
    if (cardNameLower.contains('mugg')) {
      return '1357924680123';
    }
    if (cardNameLower.contains('steers')) {
      return '2468013579124';
    }

    // Default sample barcode
    return '1111222233334';
  }
}
