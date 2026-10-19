import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';
import 'package:nova/shared/widgets/goal_progress_bar.dart';
import 'package:nova/shared/widgets/status_chip.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, required this.onTap});

  final SavingsGoal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percent = goal.savedKobo.percentOf(goal.targetKobo);
    final saved = goal.savedKobo.toNaira();
    final target = goal.targetKobo.toNaira();
    final dateLabel = DateFormat('d MMM yyyy').format(goal.targetDate);

    return Semantics(
      button: true,
      label: '${goal.name}, $percent percent saved, $saved of $target, '
          '${AppStrings.targetOn(dateLabel)}',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: AppColors.goldTint,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.track_changes_rounded,
                        size: 20.sp,
                        color: AppColors.goldDark,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: AppTextStyles.textSmSemibold.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            AppStrings.targetOn(dateLabel),
                            style: AppTextStyles.textXsRegular.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$percent%',
                      style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                GoalProgressBar(
                  percent: percent,
                  semanticLabel: '${goal.name} progress',
                ),
                SizedBox(height: 12.h),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    Text(
                      '$saved of $target',
                      style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
                    ),
                    if (goal.pendingContributionKobo > 0)
                      StatusChip.warning(
                        '+${goal.pendingContributionKobo.toNaira()} pending',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
