import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Queued offline send replays exactly once after reconnect', (tester) async {
    final hive = await HiveTestContext.create();
    final connectivity = FakeConnectivityService(online: false);
    hive.api.setOffline(true);

    await setupNovaTest(storage: hive.storage, api: hive.api, connectivity: connectivity);

    final balanceBefore = hive.api.getBalanceKobo();
    const amount = 250000;

    final sync = Get.find<SyncController>();
    final idempotencyKey = const Uuid().v4();
    await sync.enqueueSend(
      idempotencyKey: idempotencyKey,
      recipientName: 'Test User',
      recipientAccount: '08011112222',
      amountKobo: amount,
    );

    expect(hive.api.getBalanceKobo(), balanceBefore);

    connectivity.setOnline(true);
    hive.api.setOffline(false);
    await sync.syncPending();
    await sync.syncPending();

    expect(hive.api.getBalanceKobo(), balanceBefore - amount);

    final pending = await Get.find<OfflineQueueRepository>().getPendingItems();
    expect(pending, isEmpty);

    Get.reset();
    await hive.dispose();
  });

  testWidgets('Crash mid-processing recovers and debits once', (tester) async {
    final hive = await HiveTestContext.create();
    final connectivity = FakeConnectivityService(online: true);
    await setupNovaTest(storage: hive.storage, api: hive.api, connectivity: connectivity);

    final queue = Get.find<OfflineQueueRepository>();
    const amount = 100000;
    const key = 'crash-key';
    await queue.enqueue(
      OfflineQueueItem(
        id: 'crash-1',
        idempotencyKey: key,
        type: OfflineActionType.sendMoney,
        payload: {
          'recipientName': 'Crash',
          'recipientAccount': '08012345678',
          'amountKobo': amount,
        },
        status: OfflineActionStatus.processing,
        createdAt: DateTime.now(),
      ),
    );

    final before = hive.api.getBalanceKobo();
    final sync = Get.find<SyncController>();
    await sync.recoverAndSync();
    expect(hive.api.getBalanceKobo(), before - amount);

    Get.reset();
    await hive.dispose();
  });

  testWidgets('Duplicate idempotency key does not double debit', (tester) async {
    final hive = await HiveTestContext.create();
    await setupNovaTest(storage: hive.storage, api: hive.api);

    const amount = 50000;
    const key = 'dup-key';
    await hive.api.sendMoney(
      idempotencyKey: key,
      recipientName: 'Once',
      recipientAccount: '08012345678',
      amountKobo: amount,
    );
    final afterFirst = hive.api.getBalanceKobo();

    await hive.api.sendMoney(
      idempotencyKey: key,
      recipientName: 'Once',
      recipientAccount: '08012345678',
      amountKobo: amount,
    );
    expect(hive.api.getBalanceKobo(), afterFirst);

    Get.reset();
    await hive.dispose();
  });
}
