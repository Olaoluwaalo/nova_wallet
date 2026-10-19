import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/constants/route_paths.dart';
import 'package:nova/core/debug/debug_panel_sheet.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/core/utilities/nova_feedback.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:nova/features/wallet/presentation/mappers/wallet_transaction_tile.dart';
import 'package:nova/shared/widgets/balance_card.dart';
import 'package:nova/shared/widgets/offline_banner.dart';
import 'package:nova/shared/widgets/quick_action_card.dart';

class WalletHomeScreen extends GetView<WalletController> {
  static const String path = RoutePaths.walletHome;

  const WalletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.refreshWallet(userInitiated: true).then((_) {
            if (controller.loadError.value == 'offline') {
              showNovaMessage('Offline', "Can't refresh — you're offline");
            }
          }),
          child: Obx(() {
            if (controller.isLoading.value && controller.transactions.isEmpty) {
              return const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
                ],
              );
            }

            final isOffline = controller.isOffline.value;
            final txs = controller.transactions;
            final failed = controller.failedQueueItems;

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _WalletHeader(
                          lastUpdated: controller.lastRefreshedAt.value,
                          onDebugLongPress: kDebugMode ? showDebugPanel : null,
                        ),
                        SizedBox(height: 16.h),
                        if (isOffline) ...[
                          const OfflineBanner(),
                          SizedBox(height: 14.h),
                        ],
                        _BalanceSection(isOffline: isOffline),
                        SizedBox(height: 16.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: QuickActionCard(
                                icon: Icons.north_east_rounded,
                                iconBackground: AppColors.primary,
                                iconColor: AppColors.onPrimary,
                                title: AppStrings.sendMoney,
                                subtitle: AppStrings.sendMoneySubtitle,
                                onTap: () => Get.toNamed<void>(RoutePaths.sendRecipient),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: QuickActionCard(
                                icon: Icons.track_changes_rounded,
                                iconBackground: AppColors.gold,
                                iconColor: AppColors.primaryDark,
                                title: AppStrings.novaSave,
                                subtitle: AppStrings.novaSaveSubtitle,
                                onTap: () => Get.toNamed<void>(RoutePaths.saveGoals),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  AppStrings.recentActivity,
                                  style: AppTextStyles.textMdSemibold.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            if (isOffline)
                              Flexible(
                                child: Text(
                                  AppStrings.pullToRetrySync,
                                  textAlign: TextAlign.end,
                                  style: AppTextStyles.textXsRegular.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
                if (txs.isEmpty && failed.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No transactions yet',
                        style: AppTextStyles.textSmMedium,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
                    sliver: SliverList.separated(
                      itemCount: txs.length + failed.length,
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        if (index < txs.length) {
                          return WalletTransactionTileMapper.fromTransaction(txs[index]);
                        }
                        final item = failed[index - txs.length];
                        return WalletTransactionTileMapper.fromFailedQueue(
                          item,
                          onRetry: () => controller.retryFailed(item.id),
                        );
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _WalletHeader extends StatelessWidget {
  const _WalletHeader({this.lastUpdated, this.onDebugLongPress});

  final DateTime? lastUpdated;
  final VoidCallback? onDebugLongPress;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: AppColors.gold,
          child: Text(
            'NO',
            style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.primaryDark),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onLongPress: onDebugLongPress,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTextStyles.textXsRegular.copyWith(color: AppColors.textSecondary),
                ),
                Text(
                  'Nova User',
                  style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: AppStrings.notifications,
          onPressed: () {},
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.divider),
            minimumSize: const Size(kMinInteractiveDimension, kMinInteractiveDimension),
          ),
          icon: Icon(Icons.notifications_none_rounded, size: 22.sp, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _BalanceSection extends GetView<WalletController> {
  const _BalanceSection({required this.isOffline});

  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final available = controller.availableBalanceKobo.value;
    final reserved = controller.reservedKobo.value;
    final pendingCount = controller.activePendingCount.value;
    final updated = controller.lastRefreshedAt.value;
    final updatedLabel = updated == null
        ? 'Not updated yet'
        : DateFormat.jm().format(updated);

    if (isOffline) {
      return BalanceCard(
        label: AppStrings.availableToSpend,
        amountKobo: available,
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reserved > 0 && pendingCount > 0)
              Text(
                AppStrings.onHold(reserved.toNaira(), pendingCount),
                style: AppTextStyles.textXsRegular.copyWith(color: AppColors.onPrimaryMuted),
              ),
            Text(
              AppStrings.lastUpdated(updatedLabel),
              style: AppTextStyles.textXsRegular.copyWith(color: AppColors.gold),
            ),
          ],
        ),
      );
    }

    return BalanceCard(
      label: AppStrings.availableBalance,
      amountKobo: available,
      trailing: IconButton(
        tooltip: AppStrings.hideBalance,
        onPressed: () {},
        icon: Icon(Icons.visibility_outlined, size: 22.sp, color: AppColors.onPrimary),
      ),
      footer: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(color: AppColors.onlineDot, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              controller.lastUpdatedLabel,
              style: AppTextStyles.textXsRegular.copyWith(color: AppColors.onPrimaryMuted),
            ),
          ),
        ],
      ),
    );
  }
}
