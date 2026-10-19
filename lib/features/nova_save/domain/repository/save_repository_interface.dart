import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';

abstract class SaveRepositoryInterface {
  Future<List<SavingsGoal>> getGoals();
  Future<SavingsGoal> createGoal({
    required String name,
    required int targetKobo,
    required DateTime targetDate,
  });
  Future<SavingsGoal> contribute({
    required String idempotencyKey,
    required String goalId,
    required int amountKobo,
  });
}
