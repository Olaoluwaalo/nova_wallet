import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/nova_save/domain/validators/save_validators.dart';
import 'package:nova/features/nova_save/presentation/controllers/nova_save_controller.dart';
import 'package:nova/shared/widgets/app_back_header.dart';
import 'package:nova/shared/widgets/app_select_field.dart';
import 'package:nova/shared/widgets/app_text_field.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/screen_title.dart';

class SaveCreateScreen extends GetView<NovaSaveController> {
  const SaveCreateScreen({super.key});

  static const String path = RoutePaths.saveCreate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: controller.createGoalFormKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppBackHeader(title: AppStrings.createAGoal),
                      SizedBox(height: 20.h),
                      const ScreenTitle(
                        title: AppStrings.createGoalHeadline,
                        subtitle: AppStrings.createGoalSubtitle,
                      ),
                      SizedBox(height: 20.h),
                      AppTextField(
                        label: AppStrings.goalName,
                        controller: controller.goalNameController,
                        textInputAction: TextInputAction.next,
                        validator: SaveValidators.validateGoalName,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        label: AppStrings.targetAmount,
                        controller: controller.targetAmountController,
                        keyboardType: TextInputType.number,
                        prefixText: '${AppConstants.currencySymbol} ',
                        validator: SaveValidators.validateTargetAmount,
                        onChanged: (_) {
                          controller.createFormRevision.value++;
                          controller.createGoalFormKey.currentState?.validate();
                        },
                      ),
                      SizedBox(height: 16.h),
                      Obx(() {
                        final date = controller.targetDate.value;
                        final label = date == null
                            ? 'Pick a date'
                            : DateFormat('d MMM yyyy').format(date);
                        return AppSelectField(
                          label: AppStrings.targetDate,
                          value: label,
                          trailingIcon: Icons.calendar_today_outlined,
                          onTap: () => controller.pickTargetDate(context),
                        );
                      }),
                      SizedBox(height: 20.h),
                      Obx(() {
                        controller.createFormRevision.value;
                        final perMonth = controller.perMonthKoboPreview;
                        final targetKobo =
                            KoboFormatting.parseNairaInput(controller.targetAmountController.text);
                        final date = controller.targetDate.value;
                        if (perMonth == null || targetKobo == null || date == null) {
                          return const SizedBox.shrink();
                        }
                        return _MonthlyHint(
                          perMonth: perMonth.toNaira(trimZeros: true),
                          target: targetKobo.toNaira(),
                          date: DateFormat('d MMM yyyy').format(date),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                child: Obx(
                  () => PrimaryButton(
                    label: AppStrings.createGoalCta,
                    onPressed: controller.isLoading.value ? null : controller.createGoal,
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

class _MonthlyHint extends StatelessWidget {
  const _MonthlyHint({
    required this.perMonth,
    required this.target,
    required this.date,
  });

  final String perMonth;
  final String target;
  final String date;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.goldTint,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: AppColors.gold,
              child: Icon(Icons.track_changes_rounded, size: 18.sp, color: AppColors.primaryDark),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.perMonthTitle(perMonth),
                    style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.goldText),
                  ),
                  Text(
                    AppStrings.perMonthBody(target, date),
                    style: AppTextStyles.textXsRegular.copyWith(color: AppColors.goldText),
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
