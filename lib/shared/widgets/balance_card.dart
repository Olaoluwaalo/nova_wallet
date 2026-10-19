import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/shared/widgets/gradient_card.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.label,
    required this.amountKobo,
    this.trailing,
    this.footer,
  });

  final String label;
  final int amountKobo;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final amountText = amountKobo.toNaira();

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Text(
                    label,
                    style: AppTextStyles.textXsRegular.copyWith(
                      color: AppColors.onPrimaryMuted,
                    ),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 4.h),
          Semantics(
            label: '$label $amountText',
            child: ExcludeSemantics(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amountText,
                  style: AppTextStyles.displayMdSemibold.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          if (footer != null) ...[SizedBox(height: 8.h), footer!],
        ],
      ),
    );
  }
}
