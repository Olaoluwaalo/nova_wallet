import 'package:nova/core/constants/app_constants.dart';
import 'package:nova/core/services/local_storage_service.dart';
import 'package:nova/core/time/clock.dart';
import 'package:nova/core/time/uuid_generator.dart';
import 'package:nova/features/nova_save/domain/models/savings_goal_model.dart';
import 'package:nova/features/wallet/domain/models/transaction_model.dart';

class MockNovaPayApi {
  MockNovaPayApi({
    required LocalStorageService storage,
    Duration? apiLatency,
    UuidGenerator? uuidGenerator,
    Clock? clock,
  })  : _storage = storage,
        apiLatency = apiLatency ?? AppConstants.mockApiLatency,
        _uuid = uuidGenerator ?? DefaultUuidGenerator(),
        _clock = clock ?? Clock();

  final LocalStorageService _storage;
  final Duration apiLatency;
  final UuidGenerator _uuid;
  final Clock _clock;
  bool _forceOffline = false;
  bool _healthOk = true;

  static const String _balanceKey = 'balance_kobo';
  static const String _transactionsKey = 'transactions';
  static const String _goalsKey = 'goals';
  static const String _processedKeysKey = 'processed_idempotency_keys';

  void setOffline(bool value) => _forceOffline = value;

  bool get isForcedOffline => _forceOffline;

  void setHealthOk(bool value) => _healthOk = value;

  Future<bool> checkReachable() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return _healthOk && !_forceOffline;
  }

  Future<void> seedIfEmpty() async {
    final box = _storage.walletBox;
    if (!box.containsKey(_balanceKey)) {
      await box.put(_balanceKey, AppConstants.initialBalanceKobo);
      await box.put(_transactionsKey, <Map<String, dynamic>>[]);
      await box.put(_goalsKey, <Map<String, dynamic>>[]);
    }
    if (!_storage.apiStateBox.containsKey(_processedKeysKey)) {
      await _storage.apiStateBox.put(_processedKeysKey, <String>[]);
    }
  }

  Future<void> resetAllData() async {
    await _storage.walletBox.put(_balanceKey, AppConstants.initialBalanceKobo);
    await _storage.walletBox.put(_transactionsKey, <Map<String, dynamic>>[]);
    await _storage.walletBox.put(_goalsKey, <Map<String, dynamic>>[]);
    await _storage.apiStateBox.put(_processedKeysKey, <String>[]);
    await _storage.queueBox.clear();
  }

  Future<void> _simulateLatency() async {
    if (apiLatency > Duration.zero) {
      await Future<void>.delayed(apiLatency);
    }
    if (_forceOffline) {
      throw const MockApiOfflineException();
    }
    if (!_healthOk) {
      throw const MockApiNetworkException();
    }
  }

  int getBalanceKobo() => _storage.walletBox.get(_balanceKey, defaultValue: 0) as int;

  List<WalletTransaction> getTransactions() {
    final raw = _storage.walletBox.get(_transactionsKey, defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => WalletTransaction.fromJson(Map<dynamic, dynamic>.from(e as Map)))
        .toList()
        .reversed
        .toList();
  }

  List<SavingsGoal> getGoals() {
    final raw = _storage.walletBox.get(_goalsKey, defaultValue: <dynamic>[]) as List;
    return raw.map((e) => SavingsGoal.fromJson(Map<dynamic, dynamic>.from(e as Map))).toList();
  }

  Future<void> _saveTransactions(List<WalletTransaction> list) async {
    await _storage.walletBox.put(
      _transactionsKey,
      list.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> _saveGoals(List<SavingsGoal> list) async {
    await _storage.walletBox.put(
      _goalsKey,
      list.map((g) => g.toJson()).toList(),
    );
  }

  Set<String> _processedKeys() {
    final raw = _storage.apiStateBox.get(_processedKeysKey, defaultValue: <dynamic>[]) as List;
    return raw.cast<String>().toSet();
  }

  Future<void> _markKeyProcessed(String key) async {
    final keys = _processedKeys().toList();
    if (!keys.contains(key)) {
      keys.add(key);
      await _storage.apiStateBox.put(_processedKeysKey, keys);
    }
  }

  /// Promotes an offline pending row instead of appending a duplicate on sync.
  Future<WalletTransaction> _promotePendingOrAppend({
    required String idempotencyKey,
    required WalletTransaction completedTx,
  }) async {
    final txs = getTransactions().reversed.toList();
    final pendingIndex = txs.indexWhere(
      (t) => t.idempotencyKey == idempotencyKey && t.isPending,
    );
    if (pendingIndex >= 0) {
      final promoted = txs[pendingIndex].copyWith(
        isPending: false,
        createdAt: completedTx.createdAt,
      );
      txs[pendingIndex] = promoted;
      await _saveTransactions(txs);
      return promoted;
    }
    txs.add(completedTx);
    await _saveTransactions(txs);
    return completedTx;
  }

  Future<WalletTransaction> sendMoney({
    required String idempotencyKey,
    required String recipientName,
    required String recipientAccount,
    required int amountKobo,
    bool fromQueue = false,
  }) async {
    await _simulateLatency();

    if (_processedKeys().contains(idempotencyKey)) {
      final existing = getTransactions().where((t) => t.idempotencyKey == idempotencyKey).firstOrNull;
      if (existing != null) return existing;
      return WalletTransaction(
        id: _uuid.v4(),
        title: 'Send to $recipientName',
        amountKobo: -amountKobo,
        createdAt: _clock.now(),
        type: TransactionType.send,
        idempotencyKey: idempotencyKey,
      );
    }

    if (amountKobo <= 0) throw MockApiException('Invalid amount');
    if (getBalanceKobo() < amountKobo) throw MockApiException('Insufficient balance');

    final newBalance = getBalanceKobo() - amountKobo;
    await _storage.walletBox.put(_balanceKey, newBalance);

    final now = _clock.now();
    final tx = WalletTransaction(
      id: _uuid.v4(),
      title: 'Send to $recipientName',
      amountKobo: -amountKobo,
      createdAt: now,
      type: TransactionType.send,
      idempotencyKey: idempotencyKey,
    );

    final result = await _promotePendingOrAppend(
      idempotencyKey: idempotencyKey,
      completedTx: tx,
    );
    await _markKeyProcessed(idempotencyKey);
    return result;
  }

  Future<SavingsGoal> contributeToGoal({
    required String idempotencyKey,
    required String goalId,
    required int amountKobo,
  }) async {
    await _simulateLatency();

    final goals = getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index < 0) throw MockApiException('Goal not found');

    if (_processedKeys().contains(idempotencyKey)) {
      return goals[index];
    }

    if (amountKobo <= 0) throw MockApiException('Invalid amount');
    if (getBalanceKobo() < amountKobo) throw MockApiException('Insufficient balance');

    final newBalance = getBalanceKobo() - amountKobo;
    await _storage.walletBox.put(_balanceKey, newBalance);

    final updated = goals[index].copyWith(
      savedKobo: goals[index].savedKobo + amountKobo,
      pendingContributionKobo: 0,
    );
    goals[index] = updated;
    await _saveGoals(goals);

    final now = _clock.now();
    await _promotePendingOrAppend(
      idempotencyKey: idempotencyKey,
      completedTx: WalletTransaction(
        id: _uuid.v4(),
        title: 'Save: ${updated.name}',
        amountKobo: -amountKobo,
        createdAt: now,
        type: TransactionType.contribution,
        idempotencyKey: idempotencyKey,
      ),
    );
    await _markKeyProcessed(idempotencyKey);
    return updated;
  }

  Future<SavingsGoal> createGoal({
    required String name,
    required int targetKobo,
    required DateTime targetDate,
  }) async {
    await _simulateLatency();
    final goals = getGoals();
    final goal = SavingsGoal(
      id: _uuid.v4(),
      name: name,
      targetKobo: targetKobo,
      savedKobo: 0,
      targetDate: targetDate,
    );
    goals.add(goal);
    await _saveGoals(goals);
    return goal;
  }

  Future<void> addPendingTransaction(WalletTransaction tx) async {
    final txs = getTransactions().reversed.toList();
    txs.add(tx);
    await _saveTransactions(txs);
  }

  Future<void> removePendingByIdempotencyKey(String idempotencyKey) async {
    final txs = getTransactions().reversed.toList();
    txs.removeWhere((t) => t.idempotencyKey == idempotencyKey && t.isPending);
    await _saveTransactions(txs);
  }

  Future<void> finalizePendingByKey(String idempotencyKey) async {
    final txs = getTransactions().reversed.toList();
    for (var i = 0; i < txs.length; i++) {
      if (txs[i].idempotencyKey == idempotencyKey && txs[i].isPending) {
        txs[i] = txs[i].copyWith(isPending: false);
      }
    }
    await _saveTransactions(txs);
  }

  Future<void> updateGoalPending(String goalId, int pendingKobo) async {
    final goals = getGoals();
    final index = goals.indexWhere((g) => g.id == goalId);
    if (index < 0) return;
    goals[index] = goals[index].copyWith(pendingContributionKobo: pendingKobo);
    await _saveGoals(goals);
  }

  Future<void> clearGoalPending(String goalId) async {
    await updateGoalPending(goalId, 0);
  }
}

class MockApiException implements Exception {
  MockApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class MockApiOfflineException implements Exception {
  const MockApiOfflineException();
}

class MockApiNetworkException implements Exception {
  const MockApiNetworkException();
}

bool isTransientApiError(Object error) {
  return error is MockApiOfflineException || error is MockApiNetworkException;
}
