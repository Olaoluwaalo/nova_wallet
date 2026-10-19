import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'NovaPay';
  static const String currencySymbol = '₦';
  static const Size designSize = Size(390, 844);

  /// Initial demo wallet balance: ₦250,000.00
  static const int initialBalanceKobo = 25000000;

  /// Sends above this amount require biometric confirmation (stub).
  static const int biometricThresholdKobo = 5000000; // ₦50,000

  static const Duration mockApiLatency = Duration(milliseconds: 400);
}
