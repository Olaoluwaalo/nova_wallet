import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/testing/hive_test_context.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HiveTestContext hive;

  setUp(() async {
    hive = await HiveTestContext.create();
    await setupNovaTest(storage: hive.storage, api: hive.api);
  });

  tearDown(() async {
    Get.reset();
    await hive.dispose();
  });

  testWidgets('wallet primary actions meet 48dp tap targets at 2.0 text scale', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(() => tester.platformDispatcher.clearTextScaleFactorTestValue());

    await pumpNovaApp(tester, initialRoute: WalletHomeScreen.path);
    await tester.pump(const Duration(milliseconds: 400));

    final sendSize = tester.getSize(find.text('Send money'));
    final saveSize = tester.getSize(find.text('NovaSave'));
    expect(sendSize.height, greaterThanOrEqualTo(48));
    expect(saveSize.height, greaterThanOrEqualTo(48));
  });
}
