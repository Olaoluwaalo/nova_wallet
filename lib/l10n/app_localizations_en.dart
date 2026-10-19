// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get sendMoneyTitle => 'Send money';

  @override
  String get recipientLabel => 'Recipient';

  @override
  String get amountLabel => 'Amount';

  @override
  String get confirmSend => 'Confirm send';

  @override
  String get pendingWillSend => 'Pending — will send when back online';
}
