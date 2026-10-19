import 'package:flutter/material.dart';
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

  testWidgets('Wallet home golden', (tester) async {
    await pumpNovaApp(tester, initialRoute: WalletHomeScreen.path);
    await tester.pump(const Duration(milliseconds: 300));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/wallet_home.png'),
    );
  });
}
