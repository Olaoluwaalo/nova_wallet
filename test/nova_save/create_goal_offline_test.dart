import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:nova/features/nova_save/domain/validators/save_validators.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_bindings.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';

Future<void> _attachCreateGoalForm(WidgetTester tester, NovaSaveController controller) async {
  await tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(
        body: Form(
          key: controller.createGoalFormKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.goalNameController,
                validator: SaveValidators.validateGoalName,
              ),
              TextFormField(
                controller: controller.targetAmountController,
                validator: SaveValidators.validateTargetAmount,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _fillValidCreateGoalForm(NovaSaveController controller) {
  controller.goalNameController.text = 'Emergency fund';
  controller.targetAmountController.text = '50000';
  controller.targetDate.value = DateTime.now().add(const Duration(days: 60));
}

void main() {
  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  testWidgets('createGoal when device offline does not throw or add goal', (tester) async {
    await setupNovaTest(
      storage: hive.storage,
      api: hive.api,
      connectivity: FakeConnectivityService(online: false),
    );
    NovaSaveBindings().dependencies();
    final controller = Get.find<NovaSaveController>();
    await controller.loadGoals();
    final initialCount = controller.goals.length;

    await _attachCreateGoalForm(tester, controller);
    _fillValidCreateGoalForm(controller);

    await controller.createGoal();
    await controller.loadGoals();

    expect(controller.isLoading.value, isFalse);
    expect(controller.goals.length, initialCount);
    expect(controller.goalNameController.text, 'Emergency fund');
  });

  testWidgets('createGoal when API forced offline does not throw or add goal', (tester) async {
    await setupNovaTest(
      storage: hive.storage,
      api: hive.api,
      connectivity: FakeConnectivityService(online: true),
    );
    hive.api.setOffline(true);
    NovaSaveBindings().dependencies();
    final controller = Get.find<NovaSaveController>();
    await controller.loadGoals();
    final initialCount = controller.goals.length;

    await _attachCreateGoalForm(tester, controller);
    _fillValidCreateGoalForm(controller);

    await controller.createGoal();
    await controller.loadGoals();

    expect(controller.isLoading.value, isFalse);
    expect(controller.goals.length, initialCount);
  });
}
