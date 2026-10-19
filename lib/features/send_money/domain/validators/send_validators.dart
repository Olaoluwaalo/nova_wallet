import 'package:nova/core/money/kobo.dart';

class SendValidators {
  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter recipient name';
    }
    return null;
  }

  static String? validateAccountOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter account or phone number';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10 || digits.length == 11) {
      return null;
    }
    return 'Use a 10-digit account or 11-digit phone number';
  }

  static String? validateAmountKobo(int kobo, {required int availableKobo}) {
    if (kobo <= 0) {
      return 'Enter a valid amount';
    }
    if (kobo > availableKobo) {
      return 'Amount exceeds available balance';
    }
    return null;
  }

  static String? validateAmount(String? value, {required int availableKobo}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter amount';
    }
    final kobo = KoboFormatting.parseNairaInput(value);
    if (kobo == null || kobo <= 0) {
      return 'Enter a valid amount';
    }
    if (kobo > availableKobo) {
      return 'Amount exceeds available balance';
    }
    return null;
  }
}
