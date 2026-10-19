import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/testing/hive_test_context.dart';

void main() {
  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    Get.put(OfflineQueueRepository(storage: hive.storage), permanent: true);
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  test('sumActiveQueueAmountKobo sums pending and processing', () async {
    final repo = Get.find<OfflineQueueRepository>();
    await repo.enqueue(
      OfflineQueueItem(
        id: '1',
        idempotencyKey: 'k1',
        type: OfflineActionType.sendMoney,
        payload: {'amountKobo': 1000},
        status: OfflineActionStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    await repo.enqueue(
      OfflineQueueItem(
        id: '2',
        idempotencyKey: 'k2',
        type: OfflineActionType.sendMoney,
        payload: {'amountKobo': 2500},
        status: OfflineActionStatus.processing,
        createdAt: DateTime.now(),
      ),
    );
    expect(await repo.sumActiveQueueAmountKobo(), 3500);
  });

  test('recoverStaleProcessing resets processing to pending', () async {
    final repo = Get.find<OfflineQueueRepository>();
    await repo.enqueue(
      OfflineQueueItem(
        id: '1',
        idempotencyKey: 'k1',
        type: OfflineActionType.sendMoney,
        payload: {'amountKobo': 100},
        status: OfflineActionStatus.processing,
        createdAt: DateTime.now(),
      ),
    );
    await repo.recoverStaleProcessing();
    final items = await repo.getPendingItems();
    expect(items.single.status, OfflineActionStatus.pending);
  });
}
