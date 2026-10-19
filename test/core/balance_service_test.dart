import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/testing/hive_test_context.dart';

void main() {
  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    final queue = OfflineQueueRepository(storage: hive.storage);
    Get.put(queue, permanent: true);
    Get.put(BalanceService(api: hive.api, queueRepository: queue), permanent: true);
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  test('second enqueue exceeds available when sum of queue exceeds ledger', () async {
    final queue = Get.find<OfflineQueueRepository>();
    final balance = Get.find<BalanceService>();
    final ledger = hive.api.getBalanceKobo();
    await queue.enqueue(
      OfflineQueueItem(
        id: '1',
        idempotencyKey: 'a',
        type: OfflineActionType.sendMoney,
        payload: {'amountKobo': ledger - 1000},
        status: OfflineActionStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    final available = await balance.availableForNewActionsKobo();
    expect(available, 1000);
    expect(available < 5000, isTrue);
  });
}
