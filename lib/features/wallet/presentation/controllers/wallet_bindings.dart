import 'package:get/get.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/data/repository/wallet_repository.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';

class WalletBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => WalletController(
        repository: Get.find<WalletRepository>(),
        connectivity: Get.find<ConnectivityService>(),
        api: Get.find<MockNovaPayApi>(),
        queueRepository: Get.find<OfflineQueueRepository>(),
        syncController: Get.find<SyncController>(),
      ),
    );
  }
}
