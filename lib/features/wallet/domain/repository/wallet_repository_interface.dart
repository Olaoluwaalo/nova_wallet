import 'package:nova/features/wallet/domain/models/transaction_model.dart';

abstract class WalletRepositoryInterface {
  Future<int> getBalanceKobo();
  Future<int> getAvailableBalanceKobo();
  Future<List<WalletTransaction>> getTransactions();
  Future<WalletTransaction> sendMoney({
    required String idempotencyKey,
    required String recipientName,
    required String recipientAccount,
    required int amountKobo,
  });
}
