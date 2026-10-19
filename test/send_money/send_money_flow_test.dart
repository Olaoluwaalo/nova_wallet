import 'package:flutter/material.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_bindings.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_controller.dart';
import 'package:nova/features/send_money/presentation/pages/send_amount_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_confirm_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_recipient_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    await setupNovaTest(
      storage: hive.storage,
      api: hive.api,
      connectivity: FakeConnectivityService(online: true),
    );
    SendMoneyBindings().dependencies();
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  testWidgets('Send money flow creates idempotency key on confirm screen', (tester) async {
    await tester.binding.setSurfaceSize(AppConstants.designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpNovaApp(tester, initialRoute: SendRecipientScreen.path);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '08012345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'Ada Okafor');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(SendAmountScreen), findsOneWidget);
    await tester.tap(find.text('₦10,000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(SendConfirmScreen), findsOneWidget);
    final controller = Get.find<SendMoneyController>();
    expect(controller.idempotencyKey, isNotEmpty);
    expect(find.textContaining('NV-'), findsOneWidget);
  });
}
