import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nova/core/constants/app_strings.dart';
import 'package:nova/core/theme/app_colors.dart';
import 'package:nova/core/theme/app_text_styles.dart';
import 'package:nova/features/send_money/domain/constants/nigerian_banks.dart';

Future<void> showBankSelectBottomSheet(
  BuildContext context, {
  required String selected,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
              child: Text(
                AppStrings.bank,
                style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.textPrimary),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.h),
                itemCount: NigerianBanks.names.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final bank = NigerianBanks.names[index];
                  final isSelected = bank == selected;
                  return ListTile(
                    title: Text(
                      bank,
                      style: AppTextStyles.textSmMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: AppColors.primary, size: 22.sp)
                        : null,
                    onTap: () {
                      onSelected(bank);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
