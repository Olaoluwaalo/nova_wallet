import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';

void showDebugPanel() {
  if (!kDebugMode) return;
  Get.bottomSheet<void>(
    const _DebugPanelSheet(),
    isScrollControlled: true,
  );
}

class _DebugPanelSheet extends StatelessWidget {
  const _DebugPanelSheet();

  @override
  Widget build(BuildContext context) {
    final api = Get.find<MockNovaPayApi>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Debug panel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => api.setOffline(!api.isForcedOffline),
              child: Text(api.isForcedOffline ? 'Disable force offline' : 'Force offline'),
            ),
            ElevatedButton(
              onPressed: () async {
                final queue = Get.find<OfflineQueueRepository>();
                final items = await queue.getPendingItems();
                if (items.isEmpty) return;
                final first = items.first;
                await queue.update(first.copyWith(status: OfflineActionStatus.processing));
              },
              child: const Text('Simulate crash mid-processing'),
            ),
            ElevatedButton(
              onPressed: () async {
                final storage = Get.find<LocalStorageService>();
                final api = Get.find<MockNovaPayApi>();
                await storage.clearAll();
                await api.seedIfEmpty();
                if (Get.isRegistered<WalletController>()) {
                  await Get.find<WalletController>().refreshWallet();
                }
              },
              child: const Text('Reset data'),
            ),
            ElevatedButton(
              onPressed: () => Get.find<SyncController>().syncPending(),
              child: const Text('Sync now'),
            ),
          ],
        ),
      ),
    );
  }
}
