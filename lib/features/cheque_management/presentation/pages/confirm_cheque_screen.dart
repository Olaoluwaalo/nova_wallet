import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/amount_controller.dart';
import 'package:lit/core/utilities/extensions/context.dart';
import 'package:lit/core/widgets/select_account.dart';
import 'package:lit/features/cheque_management/domain/validators/cheque_validators.dart';
import 'package:lit/features/cheque_management/presentation/controllers/cheque_controller.dart';
import 'package:lit/features/cheque_management/presentation/widgets/identification_select_bottom_sheet.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:lit/shared/app_components.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ConfirmChequeScreen extends StatefulWidget {
  static String path = '/confirmChequeScreen';
  const ConfirmChequeScreen({super.key});

  @override
  State<ConfirmChequeScreen> createState() => _ConfirmChequeScreenState();
}

class _ConfirmChequeScreenState extends State<ConfirmChequeScreen> {
  final controller = Get.find<ChequeController>();

  Future<void> _selectDate() async {
    final picked = await showCustomDatePicker(context: context, initialDate: controller.state.selectedDate.value);

    if (picked != null) {
      controller.setDate(picked);
    }
  }

  void _showIdentificationBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => IdentificationSelectionBottomSheet(
        selectedIdentification: controller.state.selectedIdentification.value,
        onSelected: (identification) {
          controller.setIdentification(identification);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _selectAccount() {
    Get.to<void>(
      () => LitSelectUserAccountPage(
        onAccountSelected: (accountDetails) {
          controller.setDebitAccount(accountDetails);
          Get.back<void>();
        },
        title: context.l10n.selectAccountToDebitTitle,
        selectedAccount: controller.state.debitAccount.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final appString = context.l10n;
    return Scaffold(
      backgroundColor: appTheme.bgDefault,
      appBar: AppBar(
        backgroundColor: appTheme.bgDefault,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 55.h,
        leading: IconButton(onPressed: () => Get.back<void>(), icon: Icon(PhosphorIcons.arrowLeft())),
        title: Text(appString.confirmCheque, style: AppTextStyles.p2Medium.copyWith(fontSize: 14.sp)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: controller.confirmChequeFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appString.enterDetails,
                          style: AppTextStyles.h2.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w600),
                        ),
                        24.verticalSpace,
                        Text(
                          appString.accounts,
                          style: AppTextStyles.p2Regular.copyWith(fontSize: 12.sp, color: appTheme.textTertiary),
                        ),
                        8.verticalSpace,
                        AccountCard(
                          showBalance: false,
                          currency: controller.state.debitAccount.value?.currency ?? '',
                          accountNumber: controller.state.debitAccount.value?.number ?? appString.selectAccount,
                          accountType:
                              controller.state.debitAccount.value?.description ?? appString.tapToSelectPlaceholder,
                          onTap: _selectAccount,
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.chequeNumber,
                          controller: controller.confirm.chequeNumberController,
                          hintSize: 14.sp,
                          maxLength: 8,
                          keyboardType: TextInputType.number,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validatorFx: ChequeValidators.validateChequeNumber,
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.chequeSecurityNumber,
                          controller: controller.confirm.securityNumberController,
                          hintSize: 14.sp,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validatorFx: ChequeValidators.validateSecurityNumber,
                          keyboardType: TextInputType.number,
                        ),
                        8.verticalSpace,
                        Text(
                          appString.lastSevenDigits,
                          style: AppTextStyles.p2Regular.copyWith(fontSize: 10.sp, color: appTheme.textTertiary),
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.beneficiaryName,
                          controller: controller.confirm.beneficiaryNameController,
                          hintSize: 14.sp,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validatorFx: (value) =>
                              ChequeValidators.validateRequired(value, appString.beneficiaryNameFieldLabel),
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.amount,
                          controller: controller.confirm.amountController,
                          hintSize: 14.sp,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [CurrencyInputFormatter()],
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          validatorFx: ChequeValidators.validateAmount,
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.transactionDate,
                          controller: controller.confirm.dateController,
                          onTap: _selectDate,
                          hintSize: 14.sp,
                          readOnly: true,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          suffixIcons: [Icon(PhosphorIcons.calendarDots(PhosphorIconsStyle.fill))],
                          validatorFx: (value) =>
                              ChequeValidators.validateRequired(value, appString.transactionDateFieldLabel),
                        ),
                        20.verticalSpace,
                        AppTextField(
                          hintText: appString.modeOfIdentification,
                          controller: controller.confirm.identificationController,
                          hintSize: 14.sp,
                          readOnly: true,
                          autoValidateMode: AutovalidateMode.onUserInteraction,
                          onTap: _showIdentificationBottomSheet,
                          suffixIcons: [Icon(PhosphorIcons.caretDown(), color: appTheme.textTertiary, size: 20.r)],
                          validatorFx: (value) =>
                              ChequeValidators.validateRequired(value, appString.modeOfIdentificationFieldLabel),
                        ),

                        // Show "Other" identification field if selected
                        if (controller.state.showOtherIdentificationField.value) ...[
                          20.verticalSpace,
                          AppTextField(
                            hintText: appString.enterIdType,
                            controller: controller.confirm.otherIdentificationController,
                            hintSize: 14.sp,
                            validatorFx: (value) =>
                                ChequeValidators.validateRequired(value, appString.otherIdentificationFieldLabel),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                decoration: BoxDecoration(color: appTheme.bgDefault),
                child: Obx(
                  () => AppButton.primary(
                    label: appString.continueButtonLabel,
                    width: double.infinity,
                    onPressed: controller.state.isLoading.value ? null : controller.onConfirmChequeContinue,
                    isLoading: controller.state.isLoading.value,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
