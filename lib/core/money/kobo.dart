import 'package:nova/core/constants/app_constants.dart';

/// Money is always stored as integer kobo (1 Naira = 100 kobo).
typedef Kobo = int;

extension KoboFormatting on int {
  String formatNaira() => toNaira();

  /// 1500000 -> ₦15,000.00 (or ₦15,000 when [trimZeros] and no kobo part).
  String toNaira({bool withSymbol = true, bool trimZeros = false}) {
    final negative = this < 0;
    final abs = negative ? -this : this;
    final naira = abs ~/ 100;
    final kobo = abs % 100;
    final grouped = naira.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    final body = (trimZeros && kobo == 0)
        ? grouped
        : '$grouped.${kobo.toString().padLeft(2, '0')}';
    final symbol = withSymbol ? AppConstants.currencySymbol : '';
    return '${negative ? '-' : ''}$symbol$body';
  }

  /// Parses user input like "1,250.50" into kobo. Returns null if invalid.
  static int? parseNairaInput(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return null;
    final parts = cleaned.split('.');
    if (parts.length > 2) return null;
    final naira = int.tryParse(parts[0]);
    if (naira == null || naira < 0) return null;
    var koboPart = 0;
    if (parts.length == 2) {
      var frac = parts[1];
      if (frac.length > 2) return null;
      if (frac.length == 1) {
        frac = '${frac}0';
      }
      koboPart = int.tryParse(frac) ?? 0;
    }
    return naira * 100 + koboPart;
  }

  int percentOf(int total) {
    if (total <= 0) return 0;
    return (this * 100 ~/ total).clamp(0, 100);
  }

  int displayPercentCapped(int target) {
    if (target <= 0) return 0;
    final raw = this * 100 ~/ target;
    return raw > 100 ? 100 : raw;
  }
}
