import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/time/clock.dart';

class SaveValidators {
  static String? validateGoalName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a goal name';
    }
    return null;
  }

  static String? validateTargetAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter target amount';
    }
    final kobo = KoboFormatting.parseNairaInput(value);
    if (kobo == null || kobo <= 0) {
      return 'Target must be greater than zero';
    }
    return null;
  }

  static String? validateTargetDate(DateTime? date, {Clock? clock}) {
    if (date == null) return 'Pick a target date';
    final now = (clock ?? Clock()).now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = DateTime(date.year, date.month, date.day);
    if (!picked.isAfter(today)) {
      return 'Target date must be in the future';
    }
    return null;
  }

  static String? validateContributionKobo(int kobo, {required int availableKobo}) {
    if (kobo <= 0) {
      return 'Enter a valid amount';
    }
    if (kobo > availableKobo) {
      return 'Amount exceeds available balance';
    }
    return null;
  }

  static String? validateContribution(String? value, {required int availableKobo}) {
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
