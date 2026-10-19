import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lit/core/services/backend/api_response_model.dart';
import 'package:lit/core/state/ui_state.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/extensions/context.dart';
import 'package:lit/features/cheque_management/domain/validators/cheque_validators.dart';
import 'package:lit/features/cheque_management/presentation/controllers/cheque_controller.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:lit/shared/app_components.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChequeAuthorizationScreen extends StatefulWidget {
  static String path = '/chequeAuthorizationScreen';
  final String title;
  const ChequeAuthorizationScreen({super.key, required this.title});

  @override
  State<ChequeAuthorizationScreen> createState() => _ChequeAuthorizationScreenState();
}

class _ChequeAuthorizationScreenState extends State<ChequeAuthorizationScreen> {
  final controller = Get.find<ChequeController>();

  @override
  void dispose() {
    controller.confirm.tokenController.clear();
    super.dispose();
  }

  Future<void> onAuthorize() async {
    final appString = context.l10n;

    if (!controller.authorizationFormKey.currentState!.validate()) {
      CustomToast.showError(context, appString.enterValidToken, showAtTop: false, showLightTheme: true);
      return;
    }

    if (controller.state.currentOperation.value == 'confirm') {
      final UIState<void, ApiErrorModel> result = await controller.confirmChequeOperation();
      result.when(
        success: (_) {
          if (context.mounted) {
            CustomToast.showToast(context, appString.chequeConfirmedSuccessfully, showLightTheme: true);
          }
          controller.clearConfirmChequeForm();
          Get.until((route) => route.isFirst);
        },
        error: (message, error) {
          if (context.mounted) {
            CustomToast.showError(context, message);
          }
        },
      );
    } else if (controller.state.currentOperation.value == 'stop') {
      final UIState<void, ApiErrorModel> result = await controller.stopChequeOperation();

      result.when(
        success: (_) {
          if (context.mounted) {
            CustomToast.showToast(context, appString.chequeStoppedSuccessfully, showLightTheme: true);
          }
          controller.clearStopChequeForm();
          Get.until((route) => route.isFirst);
        },
        error: (message, error) {
          if (context.mounted) {
            CustomToast.showError(context, message);
          }
        },
      );
    }
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
        leading: IconButton(
          onPressed: () {
            Get.back<void>();
          },
          icon: Icon(PhosphorIcons.arrowLeft()),
        ),
        title: Text(widget.title, style: AppTextStyles.p2Medium.copyWith(fontSize: 14.sp)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: controller.authorizationFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appString.authorization,
                        style: AppTextStyles.h2.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w600),
                      ),
                      8.verticalSpace,
                      Text(
                        appString.authorizeWithToken,
                        style: AppTextStyles.p2Regular.copyWith(fontSize: 14.sp, color: appTheme.textSecondary),
                      ),
                      24.verticalSpace,
                      Text(
                        appString.enterToken,
                        style: AppTextStyles.p2Regular.copyWith(fontSize: 12.sp, color: appTheme.textTertiary),
                      ),
                      8.verticalSpace,
                      AppTextField(
                        hintText: appString.token,
                        controller: controller.confirm.tokenController,
                        hintSize: 14.sp,
                        maxLength: 8,
                        keyboardType: TextInputType.number,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                        validatorFx: ChequeValidators.validateToken,
                      ),
                      8.verticalSpace,
                      Text(
                        appString.tokenAccepted,
                        style: AppTextStyles.s1Regular.copyWith(
                          fontSize: 12.sp,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
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
                    onPressed: controller.state.isLoading.value ? null : () => onAuthorize(),
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
