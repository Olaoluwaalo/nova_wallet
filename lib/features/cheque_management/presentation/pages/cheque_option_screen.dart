import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lit/core/services/feature_flags/app_feature_flags.dart';
import 'package:lit/core/services/feature_flags/app_feature_flags_key_constants.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/extensions/context.dart';
import 'package:lit/features/cheque_management/presentation/pages/confirm_cheque_screen.dart';
import 'package:lit/features/cheque_management/presentation/pages/stop_cheque.dart';
import 'package:lit/features/cheque_management/presentation/widgets/check_action_tile.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChequeOptionScreen extends StatelessWidget {
  static String path = '/chequeOptionScreen';
  const ChequeOptionScreen({super.key});

  void _navigateToConfirmCheque() {
    Get.toNamed<void>(ConfirmChequeScreen.path);
  }

  void _navigateToStopCheque() {
    Get.toNamed<void>(StopChequeScreen.path);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final appString = context.l10n;
    final chequeActions = [
      if (AppFeatureFlagKey.showConfirmCheque.isEnabled)
        ChequeActionItem(
          icon: PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
          text: appString.confirmCheque,
          onTap: _navigateToConfirmCheque,
        ),
      if (AppFeatureFlagKey.showStopCheque.isEnabled)
        ChequeActionItem(
          icon: PhosphorIcons.prohibit(PhosphorIconsStyle.fill),
          text: appString.stopCheque,
          onTap: _navigateToStopCheque,
        ),
    ];

    return Scaffold(
      backgroundColor: appTheme.bgDefault,
      appBar: AppBar(
        backgroundColor: appTheme.bgDefault,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 55.h,
        leading: IconButton(onPressed: () => Get.back<void>(), icon: Icon(PhosphorIcons.arrowLeft())),
        title: Text(appString.chequeManagement, style: AppTextStyles.p2Medium.copyWith(fontSize: 14.sp)),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appString.chequeManagement,
                style: AppTextStyles.h2.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w600),
              ),
              24.verticalSpace,
              ...chequeActions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;

                return ChequeActionTile(
                  icon: action.icon,
                  text: action.text,
                  onTap: action.onTap,
                  showTopBorder: index == 2,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChequeActionItem {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ChequeActionItem({required this.icon, required this.text, required this.onTap});
}
