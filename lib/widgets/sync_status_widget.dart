import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_service.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showSyncButton;
  final bool showPendingCount;

  const SyncStatusWidget({
    Key? key,
    this.showSyncButton = true,
    this.showPendingCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        final statusDetails = syncService.getSyncStatusDetails();
        final isSyncing = statusDetails['isSyncing'] as bool;
        final pendingOps = statusDetails['pendingOperations'] as int;
        final formattedLastSync = statusDetails['formattedLastSync'] as String;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(statusDetails),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getBorderColor(statusDetails),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(statusDetails),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getStatusText(statusDetails),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _getTextColor(statusDetails),
                        fontSize: 14,
                      ),
                    ),
                    if (!isSyncing && formattedLastSync != 'Never synced')
                      Text(
                        'Last sync: $formattedLastSync',
                        style: TextStyle(
                          fontSize: 12,
                          color: _getSubtextColor(statusDetails),
                        ),
                      ),
                    if (showPendingCount && pendingOps > 0)
                      Text(
                        '$pendingOps changes pending',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (showSyncButton) ...[
                const SizedBox(width: 8),
                _buildSyncButton(context, syncService, isSyncing),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;

    if (isSyncing) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    IconData iconData;
    Color iconColor;

    if (pendingOps > 0) {
      iconData = Icons.sync_problem;
      iconColor = Colors.orange;
    } else if (syncStatus == 'error') {
      iconData = Icons.sync_problem;
      iconColor = Colors.red;
    } else if (syncStatus == 'synced') {
      iconData = Icons.sync;
      iconColor = Colors.green;
    } else {
      iconData = Icons.sync_disabled;
      iconColor = Colors.grey;
    }

    return Icon(iconData, size: 16, color: iconColor);
  }

  Widget _buildSyncButton(
      BuildContext context, SyncService syncService, bool isSyncing) {
    return InkWell(
      onTap: isSyncing ? null : () => _performSync(context, syncService),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.refresh,
          size: 18,
          color: isSyncing ? Colors.grey : Colors.blue,
        ),
      ),
    );
  }

  Future<void> _performSync(
      BuildContext context, SyncService syncService) async {
    try {
      await syncService.forcSync();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusText(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;
    final formattedLastSync = statusDetails['formattedLastSync'] as String;

    if (isSyncing) return 'Syncing...';
    if (pendingOps > 0) return 'Changes pending sync';
    if (syncStatus == 'error') return 'Sync failed';
    if (formattedLastSync == 'Never synced') return 'Not synced';
    return 'All synced';
  }

  Color _getBackgroundColor(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;

    if (isSyncing) return Colors.blue.shade50;
    if (pendingOps > 0) return Colors.orange.shade50;
    if (syncStatus == 'error') return Colors.red.shade50;
    if (syncStatus == 'synced') return Colors.green.shade50;
    return Colors.grey.shade50;
  }

  Color _getBorderColor(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;

    if (isSyncing) return Colors.blue.shade200;
    if (pendingOps > 0) return Colors.orange.shade200;
    if (syncStatus == 'error') return Colors.red.shade200;
    if (syncStatus == 'synced') return Colors.green.shade200;
    return Colors.grey.shade200;
  }

  Color _getTextColor(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;

    if (isSyncing) return Colors.blue.shade700;
    if (pendingOps > 0) return Colors.orange.shade700;
    if (syncStatus == 'error') return Colors.red.shade700;
    if (syncStatus == 'synced') return Colors.green.shade700;
    return Colors.grey.shade700;
  }

  Color _getSubtextColor(Map<String, dynamic> statusDetails) {
    final isSyncing = statusDetails['isSyncing'] as bool;
    final syncStatus = statusDetails['syncStatus'] as String;
    final pendingOps = statusDetails['pendingOperations'] as int;

    if (isSyncing) return Colors.blue.shade500;
    if (pendingOps > 0) return Colors.orange.shade500;
    if (syncStatus == 'error') return Colors.red.shade500;
    if (syncStatus == 'synced') return Colors.green.shade500;
    return Colors.grey.shade500;
  }
}

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncService>(
      builder: (context, syncService, child) {
        final pendingCount = syncService.getPendingSyncCount();

        if (pendingCount == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(12),
          ),
          constraints: const BoxConstraints(
            minWidth: 20,
            minHeight: 20,
          ),
          child: Text(
            pendingCount > 99 ? '99+' : '$pendingCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SyncService().isOffline(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.orange.shade100,
          child: Row(
            children: [
              Icon(
                Icons.wifi_off,
                size: 16,
                color: Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You\'re offline. Changes will sync when connection is restored.',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
