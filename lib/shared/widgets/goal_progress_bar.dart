import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';

/// Linear progress for a savings goal. [percent] is a whole number 0..100
/// (compute it with `savedKobo.percentOf(targetKobo)` - integer math).
class GoalProgressBar extends StatelessWidget {
  const GoalProgressBar({
    super.key,
    required this.percent,
    required this.semanticLabel,
    this.height = 8,
    this.trackColor = AppColors.divider,
    this.fillColor = AppColors.primary,
  });

  final int percent;
  final String semanticLabel;
  final double height;
  final Color trackColor;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    final barHeight = height.h;
    return Semantics(
      label: semanticLabel,
      value: '$percent percent',
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(barHeight / 2),
          child: Stack(
            children: [
              Container(height: barHeight, color: trackColor),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(height: barHeight, color: fillColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
