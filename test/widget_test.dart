import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/testing/test_harness.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';
import 'package:nova/core/testing/hive_test_context.dart';

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

  testWidgets('Wallet home shows seeded balance', (tester) async {
    await pumpNovaApp(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('250,000'), findsWidgets);
    expect(find.byType(WalletHomeScreen), findsOneWidget);
    expect(AppConstants.initialBalanceKobo, hive.api.getBalanceKobo());
  });
}
