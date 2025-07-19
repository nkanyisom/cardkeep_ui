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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            _getBarcodeIcon(card.barcodeType),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          card.cardName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Type: ${BarcodeScannerService.getBarcodeTypeDisplayName(card.barcodeType)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
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
