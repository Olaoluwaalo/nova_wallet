import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';
import 'package:nova/features/nova_save/presentation/pages/save_detail_screen.dart';
import 'package:nova/features/nova_save/presentation/widgets/goal_card.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/balance_card.dart';
import 'package:nova/shared/widgets/primary_button.dart';

class SaveGoalsScreen extends GetView<NovaSaveController> {
  const SaveGoalsScreen({super.key});

  static const String path = RoutePaths.saveGoals;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.goals.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final goals = controller.goals;
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AppBackHeader(title: AppStrings.novaSave),
                            SizedBox(height: 16.h),
                            BalanceCard(
                              label: AppStrings.totalSaved,
                              amountKobo: controller.totalSavedKobo,
                              footer: Text(
                                AppStrings.acrossGoals(goals.length),
                                style: AppTextStyles.textXsRegular.copyWith(color: AppColors.gold),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Semantics(
                              header: true,
                              child: Text(
                                AppStrings.yourGoals,
                                style: AppTextStyles.textMdSemibold.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],
                        ),
                      ),
                    ),
                    if (goals.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No goals yet',
                            style: AppTextStyles.textSmMedium,
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                        sliver: SliverList.separated(
                          itemCount: goals.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return GoalCard(
                              goal: goal,
                              onTap: () {
                                controller.openGoalDetail(goal);
                                Get.toNamed<void>(SaveDetailScreen.path, arguments: goal);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: PrimaryButton(
                label: AppStrings.createAGoal,
                icon: Icons.add_rounded,
                onPressed: () => Get.toNamed<void>(RoutePaths.saveCreate),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
