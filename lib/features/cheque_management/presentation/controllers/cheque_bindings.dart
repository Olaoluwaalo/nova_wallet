import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:lit/core/services/backend/api_client.dart';
import 'package:lit/core/services/backend/api_endpoints.dart';
import 'package:lit/features/cheque_management/data/datasources/cheque_datasource.dart';
import 'package:lit/features/cheque_management/data/repository/cheque_repository.dart';
import 'package:lit/features/cheque_management/presentation/controllers/cheque_controller.dart';

class ChequeBindings extends Bindings {
  @override
  void dependencies() {
    final apiClient = Get.put(
      ApiClient(Dio(BaseOptions(headers: {"version": "1"})), otherBaseUrl: Endpoints.chequeManagementUrl),
      tag: 'chequeApiClient',
    );

    Get.put(ChequeManagementDatasource(apiClient: apiClient));
    Get.put(ChequeRepository(dataSource: Get.find<ChequeManagementDatasource>()));
    Get.put(ChequeController(repository: Get.find<ChequeRepository>()));
  }
}
