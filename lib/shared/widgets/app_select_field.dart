import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

/// Tappable field that opens a picker (bank list, date picker...).
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.label,
    required this.value,
    this.leadingIcon,
    this.trailingIcon = Icons.keyboard_arrow_down_rounded,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? leadingIcon;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(
          child: Text(
            label,
            style: AppTextStyles.textSmMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Semantics(
          button: true,
          label: '$label, $value',
          onTap: onTap,
          excludeSemantics: true,
          child: Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
              side: const BorderSide(color: AppColors.border),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14.r),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 52.h),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Center(
                    child: Row(
                      children: [
                        if (leadingIcon != null) ...[
                          Icon(
                            leadingIcon,
                            size: 20.sp,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(width: 12.w),
                        ],
                        Expanded(
                          child: Text(
                            value,
                            style: AppTextStyles.textMdRegular.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          trailingIcon,
                          size: 20.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
