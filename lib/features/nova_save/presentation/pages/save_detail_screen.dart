import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';
import 'package:nova/shared/widgets/amount_chip.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/gradient_card.dart';
import 'package:nova/shared/widgets/goal_progress_bar.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/transaction_tile.dart';

class SaveDetailScreen extends GetView<NovaSaveController> {
  const SaveDetailScreen({super.key});

  static const String path = RoutePaths.saveDetail;

  static const List<int> _quickPicks = [500000, 1000000, 2000000];

  SavingsGoal get _goal {
    final arg = Get.arguments;
    if (arg is SavingsGoal) return arg;
    return controller.selectedGoal ?? controller.goals.first;
  }

  @override
  Widget build(BuildContext context) {
    final goal = _goal;
    final dateLabel = DateFormat('d MMM yyyy').format(goal.targetDate);

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
                      title: goal.name,
                      trailing: AppStrings.targetOn(dateLabel),
                    ),
                    SizedBox(height: 16.h),
                    _GoalHero(savedKobo: goal.savedKobo, targetKobo: goal.targetKobo),
                    SizedBox(height: 16.h),
                    Semantics(
                      header: true,
                      child: Text(
                        AppStrings.addMoney,
                        style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() {
                      final selected = controller.contributeKobo.value;
                      return Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          for (final kobo in _quickPicks)
                            AmountChip(
                              label: kobo.toNaira(trimZeros: true),
                              selected: selected == kobo,
                              onTap: () => controller.setContributeQuickPick(kobo),
                            ),
                          AmountChip(
                            label: AppStrings.other,
                            selected: !_quickPicks.contains(selected) && selected > 0,
                            onTap: () => controller.setContributeQuickPick(0),
                          ),
                        ],
                      );
                    }),
                    SizedBox(height: 8.h),
                    Obx(() => _FundingSourceRow(availableKobo: controller.availableKobo.value)),
                    if (goal.pendingContributionKobo > 0) ...[
                      SizedBox(height: 16.h),
                      Semantics(
                        header: true,
                        child: Text(
                          AppStrings.contributions,
                          style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TransactionTile(
                        title: 'Pending',
                        subtitle: AppStrings.pendingWillSend,
                        amountKobo: goal.pendingContributionKobo,
                        type: TxTileType.savings,
                        status: TxTileStatus.pending,
                        isCredit: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: Obx(() {
                final amount = controller.contributeKobo.value;
                return PrimaryButton(
                  label: AppStrings.contribute(amount.toNaira()),
                  onPressed: controller.isSubmitting.value || amount <= 0
                      ? null
                      : controller.confirmContribution,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalHero extends StatelessWidget {
  const _GoalHero({required this.savedKobo, required this.targetKobo});

  final int savedKobo;
  final int targetKobo;

  @override
  Widget build(BuildContext context) {
    final percent = savedKobo.percentOf(targetKobo);
    final remaining = (targetKobo - savedKobo).clamp(0, targetKobo);

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.savedSoFar,
                      style: AppTextStyles.textXsRegular.copyWith(color: AppColors.onPrimaryMuted),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        savedKobo.toNaira(),
                        style: AppTextStyles.displayMdSemibold.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 28.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '$percent%',
                style: AppTextStyles.displayXsSemibold.copyWith(color: AppColors.gold),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GoalProgressBar(
            percent: percent,
            height: 10,
            semanticLabel: '$percent percent of target saved',
            trackColor: AppColors.onPrimaryTrack,
            fillColor: AppColors.gold,
          ),
          SizedBox(height: 10.h),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8.w,
            runSpacing: 4.h,
            children: [
              Text(
                'Target ${targetKobo.toNaira()}',
                style: AppTextStyles.textXsRegular.copyWith(color: AppColors.onPrimaryMuted),
              ),
              Text(
                '${remaining.toNaira()} to go',
                style: AppTextStyles.textXsRegular.copyWith(color: AppColors.onPrimaryMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FundingSourceRow extends StatelessWidget {
  const _FundingSourceRow({required this.availableKobo});

  final int availableKobo;

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
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primaryTint,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 20.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.payFromWallet,
                    style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.textPrimary),
                  ),
                  Text(
                    AppStrings.availableAmount(availableKobo.toNaira()),
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
