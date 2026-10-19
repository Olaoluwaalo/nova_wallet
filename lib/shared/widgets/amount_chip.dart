import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

/// Quick-pick chip (₦5,000 / ₦10,000 / Other). Use inside a [Wrap] so it
/// reflows at large font scales.
class AmountChip extends StatelessWidget {
  const AmountChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primaryTint : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: kMinInteractiveDimension,
              minWidth: 72.w,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style:
                      (selected
                              ? AppTextStyles.textSmSemibold
                              : AppTextStyles.textSmMedium)
                          .copyWith(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
