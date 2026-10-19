import 'package:lit/features/cheque_management/domain/dto/cheque_dto.dart';

abstract class ChequeRepositoryInterface {
  Future<void> confirmCheque(ConfirmChequeDto loginDto);
  Future<void> stopCheque(StopChequeDto loginDto);
}
