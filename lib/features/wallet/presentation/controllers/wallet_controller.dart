import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/domain/models/transaction_model.dart';
import 'package:nova/features/wallet/domain/repository/wallet_repository_interface.dart';

class WalletController extends GetxController {
  WalletController({
    required WalletRepositoryInterface repository,
    required ConnectivityService connectivity,
    required MockNovaPayApi api,
    required OfflineQueueRepositoryInterface queueRepository,
    required SyncController syncController,
  })  : _repository = repository,
        _connectivity = connectivity,
        _api = api,
        _queueRepository = queueRepository,
        _syncController = syncController;

  final WalletRepositoryInterface _repository;
  final ConnectivityService _connectivity;
  final MockNovaPayApi _api;
  final OfflineQueueRepositoryInterface _queueRepository;
  final SyncController _syncController;

  final RxInt balanceKobo = 0.obs;
  final RxInt availableBalanceKobo = 0.obs;
  final RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  final RxList<OfflineQueueItem> failedQueueItems = <OfflineQueueItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isOffline = false.obs;
  final RxnString loadError = RxnString();
  final Rxn<DateTime> lastRefreshedAt = Rxn<DateTime>();
  final RxInt reservedKobo = 0.obs;
  final RxInt activePendingCount = 0.obs;

  String get lastUpdatedLabel {
    final at = lastRefreshedAt.value;
    if (at == null) return 'Not updated yet';
    return 'Updated ${DateFormat.jm().format(at)}';
  }

  @override
  void onInit() {
    super.onInit();
    refreshWallet();
  }

  Future<bool> get canReachBackend async {
    if (!await _connectivity.isOnline) return false;
    if (_api.isForcedOffline) return false;
    return _api.checkReachable();
  }

  Future<void> refreshWallet({bool userInitiated = false}) async {
    isOffline.value = !await _connectivity.isOnline || _api.isForcedOffline;
    if (userInitiated && isOffline.value) {
      loadError.value = 'offline';
      return;
    }

    isLoading.value = true;
    loadError.value = null;
    try {
      balanceKobo.value = await _repository.getBalanceKobo();
      availableBalanceKobo.value = await _repository.getAvailableBalanceKobo();
      transactions.assignAll(await _repository.getTransactions());
      failedQueueItems.assignAll(await _queueRepository.getFailedItems());
      final pending = await _queueRepository.getPendingItems();
      activePendingCount.value = pending.length;
      reservedKobo.value = (balanceKobo.value - availableBalanceKobo.value).clamp(0, balanceKobo.value);
      lastRefreshedAt.value = DateTime.now();
      isOffline.value = !await canReachBackend;
    } catch (e) {
      loadError.value = 'Failed to load wallet';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> retryFailed(String queueItemId) async {
    await _syncController.retryFailed(queueItemId);
    await refreshWallet();
  }
}
