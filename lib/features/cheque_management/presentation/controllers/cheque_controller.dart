import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lit/core/services/backend/api_response_model.dart';
import 'package:lit/core/state/ui_state.dart';
import 'package:lit/core/utilities/amount_controller.dart';
import 'package:lit/core/utilities/date_utlities.dart';
import 'package:lit/features/cheque_management/data/repository/cheque_repository.dart';
import 'package:lit/features/cheque_management/domain/dto/cheque_dto.dart';
import 'package:lit/features/cheque_management/presentation/pages/cheque_authorization.dart';
import 'package:lit/features/profile/data/model/account_details_model.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:lit/shared/toast/toast.dart';

class ChequeState {
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<String?> selectedIdentification = Rx<String?>(null);
  final Rx<AccountDetailsModel?> debitAccount = Rx<AccountDetailsModel?>(null);
  final RxBool showOtherIdentificationField = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> currentOperation = Rx<String?>(null);
}

class ConfirmControllers {
  final dateController = TextEditingController();
  final chequeNumberController = TextEditingController();
  final securityNumberController = TextEditingController();
  final beneficiaryNameController = TextEditingController();
  final amountController = AmountInputController();
  final identificationController = TextEditingController();
  final otherIdentificationController = TextEditingController();
  final tokenController = TextEditingController();
}

class StopControllers {
  final stopAccountNumberController = TextEditingController();
  final stopChequeNumberController = TextEditingController();
  final stopAmountController = AmountInputController();
  final stopReasonController = TextEditingController();
}

class ChequeController extends GetxController {
  final ChequeRepository repository;

  ChequeController({required this.repository});

  final ChequeState state = ChequeState();
  final ConfirmControllers confirm = ConfirmControllers();
  final StopControllers stop = StopControllers();

  // Form Keys
  final confirmChequeFormKey = GlobalKey<FormState>();
  final stopChequeFormKey = GlobalKey<FormState>();
  final authorizationFormKey = GlobalKey<FormState>();

  void _showError(String message) {
    final context = Get.context;
    if (context == null) {
      return;
    }
    CustomToast.showError(context, message);
  }

  void setDate(DateTime date) {
    state.selectedDate.value = date;
    confirm.dateController.text = formatDate(date);
  }

  void setIdentification(String identification) {
    state.selectedIdentification.value = identification;
    confirm.identificationController.text = identification;
    state.showOtherIdentificationField.value = identification == "Other";

    if (identification != "Other") {
      confirm.otherIdentificationController.clear();
    }
  }

  void setDebitAccount(AccountDetailsModel account) {
    state.debitAccount.value = account;
  }

  // Confirm Cheque Flow
  void onConfirmChequeContinue() {
    final appString = Get.context?.l10n;

    if (!confirmChequeFormKey.currentState!.validate()) {
      return;
    }

    if (state.debitAccount.value == null) {
      _showError(appString?.selectAccountToDebit ?? 'Please select an account to debit');
      return;
    }

    if (state.selectedIdentification.value == null) {
      _showError(appString?.selectModeOfIdentification ?? 'Please select a mode of identification');
      return;
    }

    state.currentOperation.value = 'confirm';
    Get.toNamed<void>(
      ChequeAuthorizationScreen.path,
      arguments: {'title': appString?.confirmCheque ?? 'Confirm Cheque'},
    );
  }

  // Stop Cheque Flow
  Future<void> onStopChequeContinue() async {
    final appString = Get.context?.l10n;

    if (!stopChequeFormKey.currentState!.validate()) {
      _showError(appString?.fillAllRequiredFields ?? 'Please fill all required fields correctly');
      return;
    }

    if (state.debitAccount.value == null) {
      _showError(appString?.selectAccountToDebit ?? 'Please select an account to debit');
      return;
    }

    state.currentOperation.value = 'stop';
    Get.toNamed<void>(ChequeAuthorizationScreen.path, arguments: {'title': appString?.stopCheque ?? 'Stop Cheque'});
  }

  Future<UIState<void, ApiErrorModel>> confirmChequeOperation() async {
    final appString = Get.context?.l10n;
    state.isLoading.value = true;

    try {
      final identificationMode = state.showOtherIdentificationField.value
          ? confirm.otherIdentificationController.text.trim()
          : state.selectedIdentification.value ?? '';

      final amount = confirm.amountController.numericValue;
      final formattedDate = state.selectedDate.value!.toIso8601String().split('T')[0];

      final dto = ConfirmChequeDto(
        accountNumber: state.debitAccount.value?.number ?? '',
        chequeNumber: confirm.chequeNumberController.text.trim(),
        amount: amount,
        securityNumber: confirm.securityNumberController.text.trim(),
        chequeDate: formattedDate,
        beneficiaryName: confirm.beneficiaryNameController.text.trim(),
        identificationMode: identificationMode,
        userToken: confirm.tokenController.text.trim(),
      );
      await repository.confirmCheque(dto);
      state.isLoading.value = false;
      return UISuccess();
    } on ApiErrorModel catch (e) {
      state.isLoading.value = false;
      return UIError(e.message ?? appString?.anErrorOccurred ?? "An error occurred", e);
    } catch (e) {
      state.isLoading.value = false;
      return UIError(appString?.unexpectedErrorOccurred ?? "An unexpected error occurred");
    }
  }

  Future<UIState<void, ApiErrorModel>> stopChequeOperation() async {
    final appString = Get.context?.l10n;
    state.isLoading.value = true;

    try {
      final amount = stop.stopAmountController.numericValue;
      final dto = StopChequeDto(
        accountNumber: state.debitAccount.value?.number ?? '',
        chequeNumber: stop.stopChequeNumberController.text.trim(),
        amount: amount,
        stopChequeReason: stop.stopReasonController.text.trim(),
        userToken: confirm.tokenController.text.trim(),
      );

      await repository.stopCheque(dto);

      state.isLoading.value = false;
      return UISuccess();
    } on ApiErrorModel catch (e) {
      state.isLoading.value = false;
      return UIError(e.message ?? appString?.anErrorOccurred ?? "An error occurred", e);
    } catch (e) {
      state.isLoading.value = false;
      return UIError(appString?.unexpectedErrorOccurred ?? "An unexpected error occurred");
    }
  }

  void clearConfirmChequeForm() {
    confirm.dateController.clear();
    confirm.chequeNumberController.clear();
    confirm.securityNumberController.clear();
    confirm.beneficiaryNameController.clear();
    confirm.amountController.clear();
    confirm.identificationController.clear();
    confirm.otherIdentificationController.clear();
    confirm.tokenController.clear();
    state.selectedDate.value = null;
    state.selectedIdentification.value = null;
    state.debitAccount.value = null;
    state.showOtherIdentificationField.value = false;
  }

  void clearStopChequeForm() {
    stop.stopAccountNumberController.clear();
    stop.stopChequeNumberController.clear();
    stop.stopAmountController.clear();
    stop.stopReasonController.clear();
    confirm.tokenController.clear();
    state.debitAccount.value = null;
  }

  @override
  void onClose() {
    confirm.dateController.dispose();
    confirm.chequeNumberController.dispose();
    confirm.securityNumberController.dispose();
    confirm.beneficiaryNameController.dispose();
    confirm.amountController.dispose();
    confirm.identificationController.dispose();
    confirm.otherIdentificationController.dispose();
    confirm.tokenController.dispose();
    stop.stopAccountNumberController.dispose();
    stop.stopChequeNumberController.dispose();
    stop.stopAmountController.dispose();
    stop.stopReasonController.dispose();
    super.onClose();
  }
}
