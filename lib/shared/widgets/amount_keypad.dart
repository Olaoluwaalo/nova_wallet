import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

/// On-screen numeric keypad. Pure UI: reports key presses through callbacks.
class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  static const List<List<String>> _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['00', '0', _backKey],
  ];
  static const String _backKey = 'back';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < _rows.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          Row(
            children: [
              for (var j = 0; j < _rows[i].length; j++) ...[
                if (j > 0) SizedBox(width: 8.w),
                Expanded(
                  child: _KeypadKey(
                    label: _rows[i][j],
                    isBack: _rows[i][j] == _backKey,
                    onTap: _rows[i][j] == _backKey
                        ? onBackspace
                        : () => onDigit(_rows[i][j]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _KeypadKey extends StatelessWidget {
  const _KeypadKey({
    required this.label,
    required this.onTap,
    required this.isBack,
  });

  final String label;
  final VoidCallback onTap;
  final bool isBack;

  String get _semanticLabel {
    if (isBack) return 'Delete last digit';
    if (label == '00') return 'Double zero';
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: _semanticLabel,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: AppColors.divider),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 56.h),
            child: Center(
              child: isBack
                  ? Icon(
                      Icons.backspace_outlined,
                      size: 24.sp,
                      color: AppColors.textPrimary,
                    )
                  : Text(
                      label,
                      style: AppTextStyles.textXlSemibold.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
