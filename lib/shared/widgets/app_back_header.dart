import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

class AppBackHeader extends StatelessWidget {
  const AppBackHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBack,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: AppStrings.back,
          onTap: onBack ?? Get.back,
          excludeSemantics: true,
          child: InkResponse(
            onTap: onBack ?? Get.back,
            radius: 24.r,
            child: SizedBox(
              width: kMinInteractiveDimension,
              height: kMinInteractiveDimension,
              child: Icon(
                Icons.arrow_back,
                size: 20.sp,
                weight: 3.w,
                fill: 1.w,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textXlSemibold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            textAlign: TextAlign.end,
            style: AppTextStyles.textXsRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
