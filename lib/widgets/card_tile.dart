import 'package:flutter/material.dart';
import 'package:card_keep/models/loyalty_card.dart';
import 'package:card_keep/services/barcode_scanner_service.dart';

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
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBarcodeIcon(card.barcodeType),
                  size: 28,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              
              // Card Details
              Expanded(
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
}   );
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
        trailing: PopupMenuButton<String>(
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
        onTap: onTap,
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
}
