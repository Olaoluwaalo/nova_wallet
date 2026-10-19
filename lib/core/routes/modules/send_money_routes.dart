import 'package:get/get.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_bindings.dart';
import 'package:nova/features/send_money/presentation/pages/send_amount_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_confirm_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_pending_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_recipient_screen.dart';

class SendMoneyRoutes {
  static List<GetPage<dynamic>> routes = [
    GetPage(
      name: SendRecipientScreen.path,
      page: () => const SendRecipientScreen(),
      binding: SendMoneyBindings(),
    ),
    GetPage(
      name: SendAmountScreen.path,
      page: () => const SendAmountScreen(),
    ),
    GetPage(
      name: SendConfirmScreen.path,
      page: () => const SendConfirmScreen(),
    ),
    GetPage(
      name: SendPendingScreen.path,
      page: () => const SendPendingScreen(),
    ),
  ];
}
