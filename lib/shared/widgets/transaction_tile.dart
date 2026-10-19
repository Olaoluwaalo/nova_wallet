import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';

enum TxTileType { sent, received, savings }

enum TxTileStatus { completed, pending, failed }

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amountKobo,
    required this.type,
    this.status = TxTileStatus.completed,
    this.isCredit,
    this.onRetry,
  });

  final String title;
  final String subtitle;
  final int amountKobo;
  final TxTileType type;
  final TxTileStatus status;
  final bool? isCredit;
  final VoidCallback? onRetry;

  bool get _credit => isCredit ?? type == TxTileType.received;

  @override
  Widget build(BuildContext context) {
    final style = _TileStyle.resolve(type, status);
    final amountText = '${_credit ? '+' : '-'}${amountKobo.toNaira()}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: style.border == null ? null : Border.all(color: style.border!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MergeSemantics(
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: style.iconBackground,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(style.icon, size: 20.sp, color: style.iconColor),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.textSmMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTextStyles.textXsRegular.copyWith(
                          color: style.subtitleColor,
                          fontWeight: style.subtitleWeight,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  amountText,
                  textAlign: TextAlign.end,
                  style: AppTextStyles.textSmSemibold.copyWith(
                    color: _credit ? AppColors.success : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size(
                    kMinInteractiveDimension,
                    kMinInteractiveDimension,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  AppStrings.retry,
                  style: AppTextStyles.textXsSemibold.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileStyle {
  const _TileStyle({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.subtitleColor,
    this.border,
    this.subtitleWeight = FontWeight.w400,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color subtitleColor;
  final Color? border;
  final FontWeight subtitleWeight;

  static _TileStyle resolve(TxTileType type, TxTileStatus status) {
    return switch (status) {
      TxTileStatus.pending => const _TileStyle(
        icon: Icons.schedule_rounded,
        iconBackground: AppColors.warningTint,
        iconColor: AppColors.warning,
        subtitleColor: AppColors.warning,
        border: AppColors.warningBorder,
        subtitleWeight: FontWeight.w500,
      ),
      TxTileStatus.failed => const _TileStyle(
        icon: Icons.error_outline_rounded,
        iconBackground: AppColors.errorTint,
        iconColor: AppColors.error,
        subtitleColor: AppColors.error,
        border: AppColors.errorBorder,
        subtitleWeight: FontWeight.w500,
      ),
      TxTileStatus.completed => switch (type) {
        TxTileType.sent => const _TileStyle(
          icon: Icons.north_east_rounded,
          iconBackground: AppColors.primaryTint,
          iconColor: AppColors.primary,
          subtitleColor: AppColors.textSecondary,
        ),
        TxTileType.received => const _TileStyle(
          icon: Icons.south_west_rounded,
          iconBackground: AppColors.successTint,
          iconColor: AppColors.success,
          subtitleColor: AppColors.textSecondary,
        ),
        TxTileType.savings => const _TileStyle(
          icon: Icons.track_changes_rounded,
          iconBackground: AppColors.goldTint,
          iconColor: AppColors.goldDark,
          subtitleColor: AppColors.textSecondary,
        ),
      },
    };
  }
}
