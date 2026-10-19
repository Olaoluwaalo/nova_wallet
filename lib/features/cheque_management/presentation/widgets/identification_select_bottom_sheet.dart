import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lit/core/theme/app_text_theme.dart';
import 'package:lit/core/utilities/extensions/context.dart';
import 'package:lit/l10n/l10n.dart';
import 'package:lit/shared/app_components.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class IdentificationSelectionBottomSheet extends StatelessWidget {
  const IdentificationSelectionBottomSheet({required this.onSelected, super.key, this.selectedIdentification});

  final String? selectedIdentification;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final appString = context.l10n;
    final List<String> identificationOptions = [
      appString.votersCard,
      appString.driversLicense,
      appString.nationalId,
      appString.internationalPassport,
      appString.other,
    ];
    return GenericBottomSheet(
      title: appString.modeOfIdentification,
      child: SingleChildScrollView(
        child: Column(
          children: identificationOptions.map((identification) {
            final isSelected = selectedIdentification == identification;
            return InkWell(
              onTap: () => onSelected(identification),
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: appTheme.bgDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(identification, style: AppTextStyles.p2Medium.copyWith(fontSize: 14.sp)),
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
