import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_bindings.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';

void main() {
  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    await setupNovaTest(
      storage: hive.storage,
      api: hive.api,
      connectivity: FakeConnectivityService(online: false),
    );
    NovaSaveBindings().dependencies();
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  test('Offline contribution sets pending state on goal', () async {
    final controller = Get.find<NovaSaveController>();
    final goal = await hive.api.createGoal(
      name: 'Rent',
      targetKobo: 5000000,
      targetDate: DateTime.now().add(const Duration(days: 30)),
    );
    await controller.loadGoals();
    controller.selectGoalForContribution(goal);
    controller.contributeKobo.value = 50000;

    await controller.confirmContribution();
    await controller.loadGoals();

    expect(controller.goals.first.pendingContributionKobo, greaterThan(0));
  });
}
