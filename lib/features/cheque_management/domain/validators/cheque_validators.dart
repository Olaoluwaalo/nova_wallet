import 'package:get/get.dart';
import 'package:lit/l10n/l10n.dart';

class ChequeValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      final appString = Get.context?.l10n;
      return appString?.validationFieldRequired(fieldName) ?? '$fieldName is required';
    }
    return null;
  }

  static String? validateChequeNumber(String? value) {
    final appString = Get.context?.l10n;

    if (value == null || value.trim().isEmpty) {
      return appString?.validationChequeNumberRequired ?? 'Cheque number is required';
    }
    if (value.trim().length != 8) {
      return appString?.validationChequeNumberInvalid ?? 'Cheque number must be exactly 8 characters';
    }
    return null;
  }

  static String? validateSecurityNumber(String? value) {
    final appString = Get.context?.l10n;

    if (value == null || value.trim().isEmpty) {
      return appString?.validationSecurityNumberRequired ?? 'Security number is required';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    final appString = Get.context?.l10n;

    if (value == null || value.trim().isEmpty) {
      return appString?.validationAmountRequired ?? 'Amount is required';
    }
    final amount = double.tryParse(value.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      return appString?.validationAmountInvalid ?? 'Please enter a valid amount';
    }
    return null;
  }

  static String? validateAccountNumber(String? value) {
    final appString = Get.context?.l10n;

    if (value == null || value.trim().isEmpty) {
      return appString?.validationAccountNumberRequired ?? 'Account number is required';
    }
    if (value.length < 10) {
      return appString?.validationAccountNumberInvalid ?? 'Please enter a valid account number';
    }
    return null;
  }

  static String? validateToken(String? value) {
    final appString = Get.context?.l10n;

    if (value == null || value.trim().isEmpty) {
      return appString?.validationTokenRequired ?? 'Token is required';
    }
    if (value.trim().length != 8) {
      return appString?.validationTokenInvalid ?? 'Please enter a valid token';
    }
    return null;
  }
}
