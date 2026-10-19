import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_controller.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/screen_title.dart';
import 'package:nova/shared/widgets/step_progress.dart';
import 'package:nova/shared/widgets/text_action_button.dart';

class SendConfirmScreen extends GetView<SendMoneyController> {
  const SendConfirmScreen({super.key});

  static const String path = RoutePaths.sendConfirm;

  static const int _feeKobo = 0;

  @override
  Widget build(BuildContext context) {
    final amount = controller.amountKobo.value;
    return Scaffold(
      body: SafeArea(
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
                      trailing: AppStrings.stepOf(3, 3),
                    ),
                    SizedBox(height: 12.h),
                    const StepProgress(current: 3),
                    SizedBox(height: 20.h),
                    const ScreenTitle(
                      title: AppStrings.reviewTitle,
                      subtitle: AppStrings.reviewSubtitle,
                    ),
                    SizedBox(height: 20.h),
                    _SummaryCard(
                      amountKobo: amount,
                      feeKobo: _feeKobo,
                      recipientName: controller.recipientDisplayName,
                      accountLine:
                          '${controller.recipientAccountDigits} · ${controller.selectedBank.value}',
                      reference: controller.referenceLabel,
                    ),
                    SizedBox(height: 20.h),
                    const _SafeToRetryNote(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(
                    () => PrimaryButton(
                      label: AppStrings.confirmAndSend,
                      onPressed: controller.isSubmitting.value ? null : controller.confirmSend,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  TextActionButton(
                    label: AppStrings.cancel,
                    color: AppColors.textSecondary,
                    onPressed: () => Get.until((route) => route.settings.name == WalletHomeScreen.path),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.amountKobo,
    required this.feeKobo,
    required this.recipientName,
    required this.accountLine,
    required this.reference,
  });

  final int amountKobo;
  final int feeKobo;
  final String recipientName;
  final String accountLine;
  final String reference;

  @override
  Widget build(BuildContext context) {
    final total = amountKobo + feeKobo;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.youAreSending,
            textAlign: TextAlign.center,
            style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountKobo.toNaira(),
              style: AppTextStyles.displayMdSemibold.copyWith(color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 16.h),
          _SummaryRow(label: AppStrings.to, value: recipientName),
          SizedBox(height: 12.h),
          _SummaryRow(label: AppStrings.account, value: accountLine),
          SizedBox(height: 12.h),
          const _SummaryRow(label: AppStrings.from, value: 'NovaWallet'),
          SizedBox(height: 12.h),
          _SummaryRow(label: AppStrings.fee, value: feeKobo.toNaira()),
          SizedBox(height: 12.h),
          _SummaryRow(label: AppStrings.reference, value: reference),
          SizedBox(height: 16.h),
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 16.h),
          _SummaryRow(label: AppStrings.total, value: total.toNaira(), emphasized: true),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: (emphasized ? AppTextStyles.textSmSemibold : AppTextStyles.textSmRegular)
                .copyWith(color: emphasized ? AppColors.textPrimary : AppColors.textSecondary),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: (emphasized ? AppTextStyles.textMdSemibold : AppTextStyles.textSmMedium)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeToRetryNote extends StatelessWidget {
  const _SafeToRetryNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Icon(Icons.lock_outline_rounded, size: 20.sp, color: AppColors.primaryDark),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              AppStrings.safeToRetryNote,
              style: AppTextStyles.textXsRegular.copyWith(color: AppColors.primaryDark),
            ),
          ),
        ],
      ),
    );
  }
}
