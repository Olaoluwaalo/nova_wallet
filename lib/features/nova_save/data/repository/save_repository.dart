import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';
import 'package:nova/features/nova_save/domain/repository/save_repository_interface.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';

class SaveRepository implements SaveRepositoryInterface {
  SaveRepository({required MockNovaPayApi api}) : _api = api;

  final MockNovaPayApi _api;

  @override
  Future<List<SavingsGoal>> getGoals() async => _api.getGoals();

  @override
  Future<SavingsGoal> createGoal({
    required String name,
    required int targetKobo,
    required DateTime targetDate,
  }) {
    return _api.createGoal(name: name, targetKobo: targetKobo, targetDate: targetDate);
  }

  @override
  Future<SavingsGoal> contribute({
    required String idempotencyKey,
    required String goalId,
    required int amountKobo,
  }) {
    return _api.contributeToGoal(
      idempotencyKey: idempotencyKey,
      goalId: goalId,
      amountKobo: amountKobo,
    );
  }
}
