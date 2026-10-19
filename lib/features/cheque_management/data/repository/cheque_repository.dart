import 'package:lit/features/cheque_management/data/datasources/cheque_datasource.dart';
import 'package:lit/features/cheque_management/domain/dto/cheque_dto.dart';
import 'package:lit/features/cheque_management/domain/repository/cheque_repository_interface.dart';

class ChequeRepository implements ChequeRepositoryInterface {
  final ChequeManagementDatasourceInterface dataSource;

  ChequeRepository({required this.dataSource});

  @override
  Future<void> confirmCheque(ConfirmChequeDto dto) async {
    final result = await dataSource.confirmCheque(dto);
    if (result.isSuccess) {
      return;
    } else {
      throw result.error!;
    }
  }

  @override
  Future<void> stopCheque(StopChequeDto dto) async {
    final result = await dataSource.stopCheque(dto);
    if (result.isSuccess) {
      return;
    } else {
      throw result.error!;
    }
  }
}
