import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.prefixText,
    this.suffixText,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? prefixText;
  final String? suffixText;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  static OutlineInputBorder _border(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: color, width: width),
    );
  }

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
          label: label,
          child: TextFormField(
            controller: controller,
            initialValue: controller == null ? initialValue : null,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            maxLength: maxLength,
            onChanged: onChanged,
            validator: validator,
            cursorColor: AppColors.primary,
            style: AppTextStyles.textMdRegular.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixText: prefixText,
              prefixStyle: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              suffixText: suffixText,
              suffixStyle: AppTextStyles.textXsRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              counterText: '',
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 14.h,
              ),
              border: _border(AppColors.border, 1),
              enabledBorder: _border(AppColors.border, 1),
              focusedBorder: _border(AppColors.primary, 2),
            ),
          ),
        ),
      ],
    );
  }
}
