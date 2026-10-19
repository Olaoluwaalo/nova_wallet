import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/biometric_service.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/utilities/nova_feedback.dart';
import 'package:nova/features/send_money/domain/validators/send_validators.dart';
import 'package:nova/features/send_money/presentation/models/send_pending_args.dart';
import 'package:nova/features/send_money/presentation/pages/send_amount_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_confirm_screen.dart';
import 'package:nova/features/send_money/presentation/pages/send_pending_screen.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/domain/repository/wallet_repository_interface.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';
import 'package:nova/features/wallet/presentation/pages/wallet_home_screen.dart';
import 'package:nova/core/time/uuid_generator.dart';

class SendMoneyController extends GetxController {
  SendMoneyController({
    required WalletRepositoryInterface walletRepository,
    required ConnectivityService connectivity,
    required SyncController syncController,
    required MockNovaPayApi api,
    required BalanceService balanceService,
    BiometricService? biometricService,
    UuidGenerator? uuidGenerator,
  })  : _walletRepository = walletRepository,
        _connectivity = connectivity,
        _syncController = syncController,
        _api = api,
        _balanceService = balanceService,
        _biometricService = biometricService ?? BiometricService(),
        _uuid = uuidGenerator ?? DefaultUuidGenerator();

  final WalletRepositoryInterface _walletRepository;
  final ConnectivityService _connectivity;
  final SyncController _syncController;
  final MockNovaPayApi _api;
  final BalanceService _balanceService;
  final BiometricService _biometricService;
  final UuidGenerator _uuid;

  static const int _maxAmountKobo = 999999999999;

  final recipientNameController = TextEditingController();
  final recipientAccountController = TextEditingController();
  final amountController = TextEditingController();

  final recipientFormKey = GlobalKey<FormState>();
  final amountFormKey = GlobalKey<FormState>();

  final RxBool isSubmitting = false.obs;
  final RxInt amountKobo = 0.obs;
  final RxInt availableKobo = 0.obs;
  final RxString selectedBank = 'Access Bank'.obs;

  String? _idempotencyKey;
  String? _lastRecipientSignature;
  int? _amountKobo;

  String get idempotencyKey => _idempotencyKey ??= _uuid.v4();

  String get recipientDisplayName => recipientNameController.text.trim();

  String get recipientAccountDigits =>
      recipientAccountController.text.replaceAll(RegExp(r'\D'), '');

  String get recipientInitials {
    final parts = recipientDisplayName.split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.elementAt(1)[0]}'.toUpperCase();
  }

  String get referenceLabel {
    final key = idempotencyKey.replaceAll('-', '');
    final short = key.length >= 6 ? key.substring(0, 6).toUpperCase() : key.toUpperCase();
    return 'NV-$short';
  }

  @override
  void onReady() {
    super.onReady();
    refreshAvailableBalance();
  }

  Future<void> refreshAvailableBalance() async {
    availableKobo.value = await _balanceService.availableForNewActionsKobo();
  }

  void _ensureIdempotencyKey() {
    final signature =
        '${recipientNameController.text}|${recipientAccountController.text}|$_amountKobo';
    if (_lastRecipientSignature != signature) {
      _idempotencyKey = _uuid.v4();
      _lastRecipientSignature = signature;
    }
  }

  void appendAmountKey(String key) {
    if (key == '00') {
      appendAmountDigit(0);
      appendAmountDigit(0);
      return;
    }
    final digit = int.tryParse(key);
    if (digit == null || digit < 0 || digit > 9) return;
    appendAmountDigit(digit);
  }

  void appendAmountDigit(int digit) {
    if (digit < 0 || digit > 9) return;
    final next = amountKobo.value * 10 + digit;
    if (next > _maxAmountKobo) return;
    amountKobo.value = next;
  }

  void backspaceAmount() {
    amountKobo.value = amountKobo.value ~/ 10;
  }

  void setQuickPick(int kobo) {
    amountKobo.value = kobo;
  }

  void goToAmount() {
    if (!(recipientFormKey.currentState?.validate() ?? false)) return;
    amountKobo.value = 0;
    refreshAvailableBalance();
    Get.toNamed<void>(SendAmountScreen.path);
  }

  Future<void> goToConfirm() async {
    await refreshAvailableBalance();
    final kobo = amountKobo.value;
    _amountKobo = kobo;
    _ensureIdempotencyKey();
    final error = SendValidators.validateAmountKobo(kobo, availableKobo: availableKobo.value);
    if (error != null) {
      showNovaMessage('Invalid amount', error);
      return;
    }
    Get.toNamed<void>(SendConfirmScreen.path);
  }

  Future<void> confirmSend() async {
    if (isSubmitting.value) return;
    final amount = _amountKobo ?? amountKobo.value;
    if (amount <= 0) return;

    _ensureIdempotencyKey();
    isSubmitting.value = true;

    try {
      if (amount > AppConstants.biometricThresholdKobo) {
        final context = Get.context;
        if (context == null) return;
        final ok = await _biometricService.confirmHighValueSend(context);
        if (!ok) return;
      }

      final reachable =
          await _connectivity.isOnline && !_api.isForcedOffline && await _api.checkReachable();

      if (!reachable) {
        await _enqueuePending(amount);
        return;
      }

      try {
        await _walletRepository.sendMoney(
          idempotencyKey: idempotencyKey,
          recipientName: recipientNameController.text.trim(),
          recipientAccount: recipientAccountController.text.trim(),
          amountKobo: amount,
        );
        await _finishSuccess();
      } on Object catch (error) {
        if (isTransientApiError(error)) {
          await _enqueuePending(amount);
        } else {
          showNovaMessage('Failed', error.toString());
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _enqueuePending(int amount) async {
    await _syncController.enqueueSend(
      idempotencyKey: idempotencyKey,
      recipientName: recipientNameController.text.trim(),
      recipientAccount: recipientAccountController.text.trim(),
      amountKobo: amount,
    );
    if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().refreshWallet();
    }
    Get.offAllNamed<void>(
      SendPendingScreen.path,
      arguments: SendPendingArgs(
        amountKobo: amount,
        recipientName: recipientNameController.text.trim(),
        idempotencyKey: idempotencyKey,
      ),
    );
  }

  Future<void> _finishSuccess() async {
    if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().refreshWallet();
    }
    _popToWallet();
    showNovaMessage('Success', 'Transfer sent');
  }

  void _popToWallet() {
    Get.until((route) => route.settings.name == WalletHomeScreen.path);
  }

  @override
  void onClose() {
    recipientNameController.dispose();
    recipientAccountController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
