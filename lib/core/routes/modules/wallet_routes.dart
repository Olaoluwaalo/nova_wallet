import 'package:get/get.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_bindings.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';

class WalletRoutes {
  static List<GetPage<dynamic>> routes = [
    GetPage(
      name: WalletHomeScreen.path,
      page: () => const WalletHomeScreen(),
      binding: WalletBindings(),
    ),
  ];
}
