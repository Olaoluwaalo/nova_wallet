import 'package:get/get.dart';
import 'package:nova/core/routes/modules/nova_save_routes.dart';
import 'package:nova/core/routes/modules/send_money_routes.dart';
import 'package:nova/core/routes/modules/wallet_routes.dart';

class AppPages {
  static List<GetPage<dynamic>> appPages = [
    ...WalletRoutes.routes,
    ...SendMoneyRoutes.routes,
    ...NovaSaveRoutes.routes,
  ];
}
