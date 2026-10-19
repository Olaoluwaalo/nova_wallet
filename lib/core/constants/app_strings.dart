class AppStrings {
  AppStrings._();

  static const String back = 'Back';
  static const String continueLabel = 'Continue';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String seeAll = 'See all';

  static const String goodEvening = 'Good evening';
  static const String notifications = 'Notifications';
  static const String hideBalance = 'Hide balance';
  static const String availableBalance = 'Available balance';
  static const String availableToSpend = 'Available to spend';
  static const String recentActivity = 'Recent activity';
  static const String sendMoney = 'Send money';
  static const String sendMoneySubtitle = 'To any bank';
  static const String novaSave = 'NovaSave';
  static const String novaSaveSubtitle = 'Savings goals';
  static const String pullToRetrySync = 'Pull down to retry sync';
  static String updatedJustNow(String account) =>
      'NovaWallet · $account · Updated just now';
  static String onHold(String amount, int count) =>
      '$amount on hold for $count pending actions';
  static String lastUpdated(String time) => 'Last updated $time';

  static const String offlineTitle = "You're offline";
  static const String offlineMessage =
      'Showing your last saved balance. Sends and savings are queued until '
      "you're back online.";
  static const String pendingWillSend = 'Pending — will send when back online';

  static String stepOf(int current, int total) => 'Step $current of $total';
  static const String whoSendingTitle = 'Who are you sending to?';
  static const String whoSendingSubtitle =
      "Enter their account details. We'll check the name before you pay.";
  static const String bank = 'Bank';
  static const String accountNumber = 'Account number';
  static const String accountNumberHint = '10-digit account number';
  static const String nameMatched = 'Name matched';
  static const String recentRecipients = 'Recent recipients';
  static const String amountToSend = 'Amount to send';
  static String availableAmount(String amount) => 'Available $amount';
  static const String reviewTitle = 'Review and confirm';
  static const String reviewSubtitle =
      "Check the details. Transfers can't be reversed once sent.";
  static const String youAreSending = "You're sending";
  static const String to = 'To';
  static const String account = 'Account';
  static const String from = 'From';
  static const String fee = 'Fee';
  static const String reference = 'Reference';
  static const String total = 'Total';
  static const String confirmAndSend = 'Confirm and send';
  static const String safeToRetryNote =
      'Safe to retry. This reference makes sure the money moves once. If '
      "you're offline, we'll save it and send it when you're back online.";
  static String pendingBody(String amount, String name) =>
      "$amount to $name is saved on this phone. We'll send it once, "
      "automatically, when you're connected, even if you close the app.";
  static const String savedOnPhone = 'Saved on this phone';
  static const String waitingForNetwork = 'Waiting for network';
  static const String waitingForNetworkSub =
      'No data sent yet. Your balance is on hold.';
  static String sentTo(String name) => 'Sent to $name';
  static const String notifyWhenSent = "We'll notify you when it goes through";
  static const String backToWallet = 'Back to wallet';
  static const String viewPendingActions = 'View pending actions';

  static const String totalSaved = 'Total saved';
  static String acrossGoals(int count) => 'Across $count active goals';
  static const String yourGoals = 'Your goals';
  static const String createAGoal = 'Create a goal';
  static const String createGoalHeadline = 'What are you saving for?';
  static const String createGoalSubtitle =
      'Set a target and a date. You can add money any time.';
  static const String goalName = 'Goal name';
  static const String targetAmount = 'Target amount';
  static const String targetDate = 'Target date';
  static const String createGoalCta = 'Create goal';
  static const String savedSoFar = 'Saved so far';
  static const String addMoney = 'Add money';
  static const String other = 'Other';
  static const String payFromWallet = 'Pay from NovaWallet';
  static const String contributions = 'Contributions';
  static String targetOn(String date) => 'Target $date';
  static String contribute(String amount) => 'Contribute $amount';
  static String perMonthTitle(String amount) => 'About $amount a month';
  static String perMonthBody(String target, String date) =>
      'Save this much each month to reach $target by $date.';
}
