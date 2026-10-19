import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/core/services/notification_service.dart';
import 'package:nova/features/nova_save/data/repository/save_repository.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/data/repository/wallet_repository.dart';

class InitialBinding extends Bindings {
  InitialBinding({
    LocalStorageService? storage,
    ConnectivityService? connectivity,
    MockNovaPayApi? api,
  })  : _storage = storage,
        _connectivity = connectivity,
        _api = api;

  final LocalStorageService? _storage;
  final ConnectivityService? _connectivity;
  final MockNovaPayApi? _api;

  @override
  void dependencies() {
    final storage = _storage ?? Get.find<LocalStorageService>();
    final connectivity = _connectivity ??
        (Get.isRegistered<ConnectivityService>()
            ? Get.find<ConnectivityService>()
            : Get.put<ConnectivityService>(ConnectivityServiceImpl(), permanent: true));
    final MockNovaPayApi api = _api ??
        (Get.isRegistered<MockNovaPayApi>()
            ? Get.find<MockNovaPayApi>()
            : Get.put(MockNovaPayApi(storage: storage), permanent: true));

    if (!Get.isRegistered<OfflineQueueRepository>()) {
      Get.put(OfflineQueueRepository(storage: storage), permanent: true);
    }
    final queue = Get.find<OfflineQueueRepository>();

    if (!Get.isRegistered<BalanceService>()) {
      Get.put(
        BalanceService(api: api, queueRepository: queue),
        permanent: true,
      );
    }

    if (!Get.isRegistered<WalletRepository>()) {
      Get.put(
        WalletRepository(api: api, balanceService: Get.find<BalanceService>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<SaveRepository>()) {
      Get.put(SaveRepository(api: api), permanent: true);
    }

    final NotificationService? notifications =
        Get.isRegistered<NotificationService>() ? Get.find<NotificationService>() : null;

    if (!Get.isRegistered<SyncController>()) {
      Get.put(
        SyncController(
          queueRepository: queue,
          api: api,
          connectivity: connectivity,
          balanceService: Get.find<BalanceService>(),
          notifications: notifications,
        ),
        permanent: true,
      );
    }
  }
}
