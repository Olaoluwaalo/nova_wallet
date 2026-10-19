import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/time/uuid_generator.dart';

void main() {
  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    Get.testMode = true;
    final queue = OfflineQueueRepository(storage: hive.storage);
    Get.put(queue, permanent: true);
    Get.put<ConnectivityService>(FakeConnectivityService(online: true), permanent: true);
    Get.put(BalanceService(api: hive.api, queueRepository: queue), permanent: true);
    Get.put(
      SyncController(
        queueRepository: queue,
        api: hive.api,
        connectivity: Get.find<ConnectivityService>(),
        balanceService: Get.find<BalanceService>(),
        uuidGenerator: SequentialUuidGenerator(['q1', 't1']),
      ),
      permanent: true,
    );
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  test('concurrent syncPending only debits once', () async {
    final sync = Get.find<SyncController>();
    final queue = Get.find<OfflineQueueRepository>();
    final before = hive.api.getBalanceKobo();
    await queue.enqueue(
      OfflineQueueItem(
        id: 'item-1',
        idempotencyKey: 'idem-1',
        type: OfflineActionType.sendMoney,
        payload: {
          'recipientName': 'A',
          'recipientAccount': '08012345678',
          'amountKobo': 50000,
        },
        status: OfflineActionStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    await Future.wait([sync.syncPending(), sync.syncPending()]);
    expect(hive.api.getBalanceKobo(), before - 50000);
  });
}
