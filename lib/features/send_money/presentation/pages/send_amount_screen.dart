import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/send_money/presentation/controllers/send_money_controller.dart';
import 'package:nova/shared/widgets/amount_chip.dart';
import 'package:nova/shared/widgets/amount_keypad.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/step_progress.dart';

class SendAmountScreen extends GetView<SendMoneyController> {
  const SendAmountScreen({super.key});

  static const String path = RoutePaths.sendAmount;

  static const List<int> _quickPicks = [500000, 1000000, 2000000];

  @override
  Widget build(BuildContext context) {
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
                      trailing: AppStrings.stepOf(2, 3),
                    ),
                    SizedBox(height: 12.h),
                    const StepProgress(current: 2),
                    SizedBox(height: 16.h),
                    _RecipientPill(controller: controller),
                    SizedBox(height: 20.h),
                    Obx(() => _AmountDisplay(
                          amountKobo: controller.amountKobo.value,
                          availableKobo: controller.availableKobo.value,
                        )),
                    SizedBox(height: 16.h),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final kobo in _quickPicks)
                          AmountChip(
                            label: kobo.toNaira(trimZeros: true),
                            onTap: () => controller.setQuickPick(kobo),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AmountKeypad(
                      onDigit: controller.appendAmountKey,
                      onBackspace: controller.backspaceAmount,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: PrimaryButton(
                label: AppStrings.continueLabel,
                onPressed: controller.goToConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientPill extends StatelessWidget {
  const _RecipientPill({required this.controller});

  final SendMoneyController controller;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryTint,
              child: Text(
                controller.recipientInitials,
                style: AppTextStyles.textXsSemibold.copyWith(color: AppColors.primary),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.recipientDisplayName,
                    style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    '${controller.selectedBank.value} · ${controller.recipientAccountDigits}',
                    style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
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

class _AmountDisplay extends StatelessWidget {
  const _AmountDisplay({required this.amountKobo, required this.availableKobo});

  final int amountKobo;
  final int availableKobo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.amountToSend,
          style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: 4.h),
        Semantics(
          liveRegion: true,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountKobo.toNaira(),
              style: AppTextStyles.displayLgSemibold.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          AppStrings.availableAmount(availableKobo.toNaira()),
          style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
