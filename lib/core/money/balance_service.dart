import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';

class BalanceService {
  BalanceService({
    required MockNovaPayApi api,
    required OfflineQueueRepositoryInterface queueRepository,
  })  : _api = api,
        _queueRepository = queueRepository;

  final MockNovaPayApi _api;
  final OfflineQueueRepositoryInterface _queueRepository;

  int ledgerBalanceKobo() => _api.getBalanceKobo();

  Future<int> reservedFromQueueKobo() => _queueRepository.sumActiveQueueAmountKobo();

  Future<int> availableForNewActionsKobo() async {
    final reserved = await reservedFromQueueKobo();
    return ledgerBalanceKobo() - reserved;
  }
}
