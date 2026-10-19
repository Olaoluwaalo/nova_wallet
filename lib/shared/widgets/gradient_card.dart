import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/theme/app_colors.dart';

/// Navy gradient card with the gold ring ornament (balance / goal hero).
class GradientCard extends StatelessWidget {
  const GradientCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.cardGradient),
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Positioned(
                right: -48.w,
                top: -48.h,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.ornamentGold,
                          width: 28.w,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    padding ?? EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 22.h),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
