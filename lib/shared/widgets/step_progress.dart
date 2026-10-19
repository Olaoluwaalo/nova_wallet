import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/theme/app_colors.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.current, this.total = 3});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.stepOf(current, total),
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var i = 1; i <= total; i++) ...[
              if (i > 1) SizedBox(width: 6.w),
              Expanded(
                child: Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: i <= current ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
