import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/features/nova_save/data/repository/save_repository.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';

class NovaSaveBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => NovaSaveController(
        repository: Get.find<SaveRepository>(),
        connectivity: Get.find<ConnectivityService>(),
        syncController: Get.find<SyncController>(),
        api: Get.find<MockNovaPayApi>(),
        balanceService: Get.find<BalanceService>(),
      ),
    );
  }
}
