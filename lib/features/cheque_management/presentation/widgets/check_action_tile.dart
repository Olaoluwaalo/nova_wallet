import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lit/core/constants/app_spacings.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/extensions/context.dart';

class ChequeActionTile extends StatelessWidget {
  const ChequeActionTile({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key,
    this.showTopBorder = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool showTopBorder;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: appTheme.subtleBorder),
            top: showTopBorder ? BorderSide(color: appTheme.subtleBorder) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: appTheme.infoColor.withValues(alpha: .08),
              child: Icon(icon, size: 18.r, color: appTheme.iconActive),
            ),
            12.horizontalSpace,
            Expanded(
              child: Text(text, style: AppTextStyles.p2Medium.copyWith(color: appTheme.textPrimary)),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.r, color: appTheme.textTertiary),
          ],
        ),
      ),
    );
  }
}
