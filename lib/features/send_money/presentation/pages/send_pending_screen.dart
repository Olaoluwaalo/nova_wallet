import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/send_money/presentation/models/send_pending_args.dart';
import 'package:nova/shared/widgets/primary_button.dart';
import 'package:nova/shared/widgets/text_action_button.dart';

class SendPendingScreen extends StatelessWidget {
  const SendPendingScreen({super.key});

  static const String path = RoutePaths.sendPending;

  SendPendingArgs get _args {
    final raw = Get.arguments;
    if (raw is SendPendingArgs) return raw;
    return const SendPendingArgs(
      amountKobo: 0,
      recipientName: 'Recipient',
      idempotencyKey: 'unknown',
    );
  }

  String _referenceLabel(String idempotencyKey) {
    final key = idempotencyKey.replaceAll('-', '');
    final short = key.length >= 6 ? key.substring(0, 6).toUpperCase() : key.toUpperCase();
    return 'NV-$short';
  }

  @override
  Widget build(BuildContext context) {
    final args = _args;
    final reference = _referenceLabel(args.idempotencyKey);
    final sentTitle = AppStrings.sentTo(args.recipientName);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 88.w,
                        height: 88.w,
                        decoration: const BoxDecoration(
                          color: AppColors.warningIconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.schedule_rounded, size: 40.sp, color: AppColors.warning),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Semantics(
                      liveRegion: true,
                      header: true,
                      child: Text(
                        AppStrings.pendingWillSend,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayXsSemibold.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.pendingBody(args.amountKobo.toNaira(), args.recipientName),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.textSmRegular.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Column(
                        children: [
                          _TimelineStep(
                            state: _StepState.done,
                            title: AppStrings.savedOnPhone,
                            subtitle: 'Reference $reference',
                          ),
                          const _TimelineStep(
                            state: _StepState.current,
                            title: AppStrings.waitingForNetwork,
                            subtitle: AppStrings.waitingForNetworkSub,
                          ),
                          _TimelineStep(
                            state: _StepState.upcoming,
                            title: sentTitle,
                            subtitle: AppStrings.notifyWhenSent,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: AppStrings.backToWallet,
                    onPressed: () => Get.offAllNamed<void>(RoutePaths.walletHome),
                  ),
                  SizedBox(height: 4.h),
                  TextActionButton(
                    label: AppStrings.viewPendingActions,
                    onPressed: () => Get.offAllNamed<void>(RoutePaths.walletHome),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _StepState { done, current, upcoming }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.state,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });

  final _StepState state;
  final String title;
  final String subtitle;
  final bool isLast;

  String get _statusWord => switch (state) {
        _StepState.done => 'Done',
        _StepState.current => 'In progress',
        _StepState.upcoming => 'Next',
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$_statusWord. $title. $subtitle',
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                _Marker(state: state),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: state == _StepState.done ? AppColors.success : AppColors.border,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        title,
                        style: AppTextStyles.textSmSemibold.copyWith(
                          color: state == _StepState.upcoming
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.state});

  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final size = 28.w;
    switch (state) {
      case _StepState.done:
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: Icon(Icons.check_rounded, size: 16.sp, color: AppColors.onPrimary),
        );
      case _StepState.current:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.warningIconBg,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.warningAccent, width: 2),
          ),
        );
      case _StepState.upcoming:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2),
          ),
        );
    }
  }
}
