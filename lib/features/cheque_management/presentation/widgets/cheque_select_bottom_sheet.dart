import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/extensions/context.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:lit/shared/modals/generic_bottom_sheet.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ChequeSelectionBottomSheet extends StatelessWidget {
  const ChequeSelectionBottomSheet({required this.onSelected, super.key, this.selectedCheque});

  final String? selectedCheque;
  final ValueChanged<String> onSelected;

  static final List<String> chequeNumbers = ["112UU8QR", "R112UU8", "QPPO112U", "U8Q00R"];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final appString = context.l10n;
    return GenericBottomSheet(
      title: appString.selectCheque,
      child: SingleChildScrollView(
        child: Column(
          children: chequeNumbers.map((cheque) {
            final isSelected = selectedCheque == cheque;

            return InkWell(
              onTap: () => onSelected(cheque),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: appTheme.bgDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(cheque, style: AppTextStyles.p2Medium.copyWith(fontSize: 14.sp)),
                    if (isSelected) Icon(PhosphorIcons.checkCircle(), color: appTheme.infoColor, size: 20.r),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
