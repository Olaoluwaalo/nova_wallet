import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  const StatusChip.warning(String label, {Key? key})
    : this(
        key: key,
        label: label,
        background: AppColors.warningTint,
        foreground: AppColors.warning,
        border: AppColors.warningBorder,
      );

  const StatusChip.error(String label, {Key? key})
    : this(
        key: key,
        label: label,
        background: AppColors.errorTint,
        foreground: AppColors.error,
        border: AppColors.errorBorder,
      );

  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: AppTextStyles.textXsMedium.copyWith(color: foreground),
      ),
    );
  }
}
