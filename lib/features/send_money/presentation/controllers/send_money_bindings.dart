import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_controller.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/data/repository/wallet_repository.dart';

class SendMoneyBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SendMoneyController(
        walletRepository: Get.find<WalletRepository>(),
        connectivity: Get.find<ConnectivityService>(),
        syncController: Get.find<SyncController>(),
        api: Get.find<MockNovaPayApi>(),
        balanceService: Get.find<BalanceService>(),
      ),
    );
  }
}
