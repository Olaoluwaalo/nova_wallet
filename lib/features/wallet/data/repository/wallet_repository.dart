import 'package:nova/core/money/balance_service.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/domain/models/transaction_model.dart';
import 'package:nova/features/wallet/domain/repository/wallet_repository_interface.dart';

class WalletRepository implements WalletRepositoryInterface {
  WalletRepository({
    required MockNovaPayApi api,
    required BalanceService balanceService,
  })  : _api = api,
        _balanceService = balanceService;

  final MockNovaPayApi _api;
  final BalanceService _balanceService;

  @override
  Future<int> getBalanceKobo() async => _api.getBalanceKobo();

  @override
  Future<int> getAvailableBalanceKobo() async => _balanceService.availableForNewActionsKobo();

  @override
  Future<List<WalletTransaction>> getTransactions() async => _api.getTransactions();

  @override
  Future<WalletTransaction> sendMoney({
    required String idempotencyKey,
    required String recipientName,
    required String recipientAccount,
    required int amountKobo,
  }) {
    return _api.sendMoney(
      idempotencyKey: idempotencyKey,
      recipientName: recipientName,
      recipientAccount: recipientAccount,
      amountKobo: amountKobo,
    );
  }
}
