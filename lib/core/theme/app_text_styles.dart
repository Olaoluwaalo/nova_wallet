import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _family = 'Poppins';

  static TextStyle get displayLgSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 40.sp,
        height: 48 / 40,
      );

  static TextStyle get displayMdSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 32.sp,
        height: 40 / 32,
      );

  static TextStyle get displayXsSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 24.sp,
        height: 32 / 24,
      );

  static TextStyle get textXlSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 20.sp,
        height: 28 / 20,
      );

  static TextStyle get textMdRegular => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w400,
        fontSize: 16.sp,
        height: 24 / 16,
      );

  static TextStyle get textMdMedium => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w500,
        fontSize: 16.sp,
        height: 24 / 16,
      );

  static TextStyle get textMdSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 16.sp,
        height: 24 / 16,
      );

  static TextStyle get textSmRegular => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
        height: 20 / 14,
      );

  static TextStyle get textSmMedium => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        height: 20 / 14,
      );

  static TextStyle get textSmSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        height: 20 / 14,
      );

  static TextStyle get textXsRegular => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w400,
        fontSize: 12.sp,
        height: 18 / 12,
      );

  static TextStyle get textXsMedium => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
        height: 18 / 12,
      );

  static TextStyle get textXsSemibold => TextStyle(
        fontFamily: _family,
        fontWeight: FontWeight.w600,
        fontSize: 12.sp,
        height: 18 / 12,
      );
}
