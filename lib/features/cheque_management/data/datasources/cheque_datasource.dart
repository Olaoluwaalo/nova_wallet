import 'package:lit/core/services/backend/api_client.dart';
import 'package:lit/core/services/backend/api_endpoints.dart';
import 'package:lit/core/services/backend/api_response_model.dart';
import 'package:lit/features/cheque_management/domain/dto/cheque_dto.dart';

abstract class ChequeManagementDatasourceInterface {
  Future<ApiResult<void>> confirmCheque(ConfirmChequeDto dto);
  Future<ApiResult<void>> stopCheque(StopChequeDto dto);
}

class ChequeManagementDatasource implements ChequeManagementDatasourceInterface {
  final ApiClient apiClient;

  ChequeManagementDatasource({required this.apiClient});

  @override
  Future<ApiResult<void>> confirmCheque(ConfirmChequeDto dto) async {
    return apiClient.post(Endpoints.confirmCheque, convertData: (data) {}, data: dto.toJson());
  }

  @override
  Future<ApiResult<void>> stopCheque(StopChequeDto dto) async {
    return apiClient.post(Endpoints.stopCheque, convertData: (data) {}, data: dto.toJson());
  }
}
