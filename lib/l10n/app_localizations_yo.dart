// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Yoruba (`yo`).
class AppLocalizationsYo extends AppLocalizations {
  AppLocalizationsYo([String locale = 'yo']) : super(locale);

  @override
  String get sendMoneyTitle => 'Fi owó ránṣẹ́';

  @override
  String get recipientLabel => 'Olùgbà';

  @override
  String get amountLabel => 'Iye owó';

  @override
  String get confirmSend => 'Jẹ́risi ríránṣẹ́';

  @override
  String get pendingWillSend =>
      'Ń dúró — a ó ránṣẹ́ nígbà tí ó bá wà lórí íntánẹ́ẹ̀tì';
}
