import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/money/kobo.dart';
import 'package:nova/core/offline/sync_controller.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/time/uuid_generator.dart';
import 'package:nova/core/utilities/nova_feedback.dart';
import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';
import 'package:nova/features/nova_save/domain/repository/save_repository_interface.dart';
import 'package:nova/features/nova_save/domain/validators/save_validators.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';

class NovaSaveController extends GetxController {
  NovaSaveController({
    required SaveRepositoryInterface repository,
    required ConnectivityService connectivity,
    required SyncController syncController,
    required MockNovaPayApi api,
    required BalanceService balanceService,
    UuidGenerator? uuidGenerator,
  })  : _repository = repository,
        _connectivity = connectivity,
        _syncController = syncController,
        _api = api,
        _balanceService = balanceService,
        _uuid = uuidGenerator ?? DefaultUuidGenerator();

  final SaveRepositoryInterface _repository;
  final ConnectivityService _connectivity;
  final SyncController _syncController;
  final MockNovaPayApi _api;
  final BalanceService _balanceService;
  final UuidGenerator _uuid;

  static const int _maxAmountKobo = 999999999999;

  final RxList<SavingsGoal> goals = <SavingsGoal>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxInt contributeKobo = 0.obs;
  final RxInt availableKobo = 0.obs;
  final Rxn<DateTime> targetDate = Rxn<DateTime>();
  final RxInt createFormRevision = 0.obs;

  final goalNameController = TextEditingController();
  final targetAmountController = TextEditingController();
  final contributeAmountController = TextEditingController();
  final createGoalFormKey = GlobalKey<FormState>();

  SavingsGoal? selectedGoal;
  String? _contributeIdempotencyKey;

  int get totalSavedKobo => goals.fold<int>(0, (sum, g) => sum + g.savedKobo);

  int? get perMonthKoboPreview {
    final targetKobo = KoboFormatting.parseNairaInput(targetAmountController.text);
    final date = targetDate.value;
    if (targetKobo == null || targetKobo <= 0 || date == null) return null;
    final now = DateTime.now();
    final months = (date.year - now.year) * 12 + (date.month - now.month);
    if (months <= 0) return null;
    return targetKobo ~/ months;
  }

  @override
  void onInit() {
    super.onInit();
    loadGoals();
  }

  @override
  void onReady() {
    super.onReady();
    refreshAvailableBalance();
  }

  Future<void> refreshAvailableBalance() async {
    availableKobo.value = await _balanceService.availableForNewActionsKobo();
  }

  Future<void> loadGoals() async {
    isLoading.value = true;
    try {
      goals.assignAll(await _repository.getGoals());
    } finally {
      isLoading.value = false;
    }
  }

  SavingsGoal? goalById(String id) => goals.firstWhereOrNull((g) => g.id == id);

  void openGoalDetail(SavingsGoal goal) {
    selectedGoal = goal;
    contributeKobo.value = 0;
    _contributeIdempotencyKey = _uuid.v4();
    refreshAvailableBalance();
  }

  void appendContributeDigit(int digit) {
    if (digit < 0 || digit > 9) return;
    final next = contributeKobo.value * 10 + digit;
    if (next > _maxAmountKobo) return;
    contributeKobo.value = next;
  }

  void backspaceContribute() {
    contributeKobo.value = contributeKobo.value ~/ 10;
  }

  void setContributeQuickPick(int kobo) {
    contributeKobo.value = kobo;
  }

  Future<void> pickTargetDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: targetDate.value ?? now.add(const Duration(days: 30)),
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      targetDate.value = picked;
      createFormRevision.value++;
    }
  }

  Future<void> createGoal() async {
    final date = targetDate.value;
    final dateError = SaveValidators.validateTargetDate(date);
    if (dateError != null) {
      showNovaMessage('Invalid date', dateError);
      return;
    }
    if (!(createGoalFormKey.currentState?.validate() ?? false)) {
      showNovaMessage('Invalid', 'Please fill in all required fields.');
      return;
    }
    final targetKobo = KoboFormatting.parseNairaInput(targetAmountController.text);
    if (targetKobo == null || targetKobo <= 0) {
      showNovaMessage('Invalid target', 'Enter a valid target amount');
      return;
    }
    isLoading.value = true;
    try {
      await _repository.createGoal(
        name: goalNameController.text.trim(),
        targetKobo: targetKobo,
        targetDate: date!,
      );
      goalNameController.clear();
      targetAmountController.clear();
      targetDate.value = null;
      await loadGoals();
      Get.back<void>();
    } finally {
      isLoading.value = false;
    }
  }

  void selectGoalForContribution(SavingsGoal goal) {
    openGoalDetail(goal);
  }

  Future<void> confirmContribution() async {
    if (isSubmitting.value) return;
    final goal = selectedGoal;
    if (goal == null) return;

    await refreshAvailableBalance();
    final amountKobo = contributeKobo.value;
    final amountError = SaveValidators.validateContributionKobo(
      amountKobo,
      availableKobo: availableKobo.value,
    );
    if (amountError != null) {
      showNovaMessage('Invalid amount', amountError);
      return;
    }
    _contributeIdempotencyKey ??= _uuid.v4();

    isSubmitting.value = true;
    try {
      final reachable =
          await _connectivity.isOnline && !_api.isForcedOffline && await _api.checkReachable();

      if (!reachable) {
        await _enqueue(goal, amountKobo);
        return;
      }

      try {
        await _repository.contribute(
          idempotencyKey: _contributeIdempotencyKey!,
          goalId: goal.id,
          amountKobo: amountKobo,
        );
        if (Get.isRegistered<WalletController>()) {
          await Get.find<WalletController>().refreshWallet();
        }
        Get.back<void>();
        showNovaMessage('Success', 'Contribution recorded');
        await loadGoals();
      } on Object catch (error) {
        if (isTransientApiError(error)) {
          await _enqueue(goal, amountKobo);
        } else {
          showNovaMessage('Failed', error.toString());
        }
      }
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _enqueue(SavingsGoal goal, int amountKobo) async {
    await _syncController.enqueueContribution(
      idempotencyKey: _contributeIdempotencyKey!,
      goalId: goal.id,
      amountKobo: amountKobo,
      goalName: goal.name,
    );
    Get.back<void>();
    showNovaMessage('Pending', 'Pending — will send when back online');
    await loadGoals();
  }

  @override
  void onClose() {
    goalNameController.dispose();
    targetAmountController.dispose();
    contributeAmountController.dispose();
    super.onClose();
  }
}
