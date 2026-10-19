import 'package:flutter/material.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

class TextActionButton extends StatelessWidget {
  const TextActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(
          kMinInteractiveDimension,
          kMinInteractiveDimension,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(
        label,
        style: AppTextStyles.textSmSemibold.copyWith(color: color),
      ),
    );
  }
}
