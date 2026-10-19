import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/send_money/domain/validators/send_validators.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_controller.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/app_select_field.dart';
import 'package:nova/shared/widgets/app_text_field.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/screen_title.dart';
import 'package:nova/shared/widgets/step_progress.dart';

class SendRecipientScreen extends GetView<SendMoneyController> {
  const SendRecipientScreen({super.key});

  static const String path = RoutePaths.sendRecipient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: controller.recipientFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppBackHeader(
                        title: AppStrings.sendMoney,
                        trailing: AppStrings.stepOf(1, 3),
                      ),
                      SizedBox(height: 12.h),
                      const StepProgress(current: 1),
                      SizedBox(height: 20.h),
                      const ScreenTitle(
                        title: AppStrings.whoSendingTitle,
                        subtitle: AppStrings.whoSendingSubtitle,
                      ),
                      SizedBox(height: 20.h),
                      Obx(
                        () => AppSelectField(
                          label: AppStrings.bank,
                          value: controller.selectedBank.value,
                          leadingIcon: Icons.account_balance_outlined,
                          onTap: () {},
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        label: AppStrings.accountNumber,
                        controller: controller.recipientAccountController,
                        hintText: AppStrings.accountNumberHint,
                        keyboardType: TextInputType.number,
                        maxLength: 11,
                        validator: SendValidators.validateAccountOrPhone,
                        suffixText: '',
                        onChanged: (_) => controller.recipientFormKey.currentState?.validate(),
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        label: 'Recipient name',
                        controller: controller.recipientNameController,
                        hintText: 'e.g. Ada Okafor',
                        textInputAction: TextInputAction.done,
                        validator: SendValidators.validateRecipientName,
                      ),
                      if (controller.recipientDisplayName.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _NameMatchedBanner(name: controller.recipientDisplayName.toUpperCase()),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child: PrimaryButton(
                  label: AppStrings.continueLabel,
                  onPressed: controller.goToAmount,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameMatchedBanner extends StatelessWidget {
  const _NameMatchedBanner({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.successTint,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.successBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.surface,
              child: Icon(Icons.check_rounded, size: 18.sp, color: AppColors.success),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.nameMatched,
                    style: AppTextStyles.textXsRegular.copyWith(color: AppColors.success),
                  ),
                  Text(
                    name,
                    style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
