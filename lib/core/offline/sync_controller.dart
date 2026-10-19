import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nova/core/money/balance_service.dart';
import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/core/offline/offline_queue_repository.dart';
import 'package:nova/core/services/connectivity_service.dart';
import 'package:nova/core/services/notification_service.dart';
import 'package:nova/core/time/uuid_generator.dart';
import 'package:nova/core/utilities/sync_announcements.dart';
import 'package:nova/features/wallet/data/datasources/mock_novapay_api.dart';
import 'package:nova/features/wallet/domain/models/transaction_model.dart';
import 'package:nova/features/wallet/presentation/controllers/wallet_controller.dart';

class SyncController extends GetxService {
  SyncController({
    required OfflineQueueRepositoryInterface queueRepository,
    required MockNovaPayApi api,
    required ConnectivityService connectivity,
    required BalanceService balanceService,
    NotificationService? notifications,
    UuidGenerator? uuidGenerator,
  })  : _queueRepository = queueRepository,
        _api = api,
        _connectivity = connectivity,
        _balanceService = balanceService,
        _notifications = notifications,
        _uuid = uuidGenerator ?? DefaultUuidGenerator();

  final OfflineQueueRepositoryInterface _queueRepository;
  final MockNovaPayApi _api;
  final ConnectivityService _connectivity;
  final BalanceService _balanceService;
  final NotificationService? _notifications;
  final UuidGenerator _uuid;

  StreamSubscription<bool>? _connectivitySub;
  Future<void>? _syncInFlight;

  @override
  void onInit() {
    super.onInit();
    if (Get.testMode) {
      return;
    }
    if (_connectivity is ConnectivityServiceImpl) {
      _connectivity.startListening();
    }
    _connectivitySub = _connectivity.onConnectivityChanged.listen((online) {
      if (online) unawaited(syncPending());
    });
    unawaited(_bootstrapSync());
  }

  Future<void> _bootstrapSync() async {
    await _queueRepository.recoverStaleProcessing();
    await syncPending();
  }

  @override
  void onClose() {
    _connectivitySub?.cancel();
    super.onClose();
  }

  Future<void> syncPending() {
    final inFlight = _syncInFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final future = _runSync();
    _syncInFlight = future;
    return future.whenComplete(() => _syncInFlight = null);
  }

  Future<void> _runSync() async {
    if (!await _connectivity.isOnline) return;
    if (_api.isForcedOffline) return;
    if (!await _api.checkReachable()) return;

    await _queueRepository.recoverStaleProcessing();

    final items = await _queueRepository.getPendingItems();
    for (final item in items) {
      if (item.status == OfflineActionStatus.completed) continue;

      final processing = item.copyWith(status: OfflineActionStatus.processing);
      await _queueRepository.update(processing);

      try {
        switch (item.type) {
          case OfflineActionType.sendMoney:
            await _api.sendMoney(
              idempotencyKey: item.idempotencyKey,
              recipientName: item.payload['recipientName'] as String,
              recipientAccount: item.payload['recipientAccount'] as String,
              amountKobo: item.payload['amountKobo'] as int,
              fromQueue: true,
            );
            await _api.finalizePendingByKey(item.idempotencyKey);
            await _notifications?.showSyncSuccess('Transfer synced');
            announceSyncState('Synced');
          case OfflineActionType.contributeGoal:
            await _api.contributeToGoal(
              idempotencyKey: item.idempotencyKey,
              goalId: item.payload['goalId'] as String,
              amountKobo: item.payload['amountKobo'] as int,
            );
            await _api.finalizePendingByKey(item.idempotencyKey);
            await _api.clearGoalPending(item.payload['goalId'] as String);
            await _notifications?.showSyncSuccess('Contribution synced');
            announceSyncState('Synced');
        }
        await _queueRepository.remove(item.id);
      } on Object catch (error) {
        if (isTransientApiError(error)) {
          await _queueRepository.update(
            item.copyWith(
              status: OfflineActionStatus.pending,
              errorMessage: 'Will retry when online',
            ),
          );
        } else {
          await _queueRepository.update(
            item.copyWith(
              status: OfflineActionStatus.failed,
              errorMessage: error.toString(),
            ),
          );
          await _api.removePendingByIdempotencyKey(item.idempotencyKey);
          if (item.type == OfflineActionType.contributeGoal) {
            await _api.clearGoalPending(item.payload['goalId'] as String);
          }
        }
      }
    }
    await _refreshWallet();
  }

  Future<void> retryFailed(String queueItemId) async {
    await _queueRepository.retryFailed(queueItemId);
    await syncPending();
  }

  Future<void> enqueueSend({
    required String idempotencyKey,
    required String recipientName,
    required String recipientAccount,
    required int amountKobo,
  }) async {
    final available = await _balanceService.availableForNewActionsKobo();
    if (amountKobo > available) {
      throw MockApiException('Insufficient available balance');
    }

    await _api.addPendingTransaction(
      WalletTransaction(
        id: _uuid.v4(),
        title: 'Send to $recipientName',
        amountKobo: -amountKobo,
        createdAt: DateTime.now(),
        type: TransactionType.send,
        isPending: true,
        idempotencyKey: idempotencyKey,
      ),
    );
    await _queueRepository.enqueue(
      OfflineQueueItem(
        id: _uuid.v4(),
        idempotencyKey: idempotencyKey,
        type: OfflineActionType.sendMoney,
        payload: {
          'recipientName': recipientName,
          'recipientAccount': recipientAccount,
          'amountKobo': amountKobo,
        },
        status: OfflineActionStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    announceSyncState('Pending');
    await _refreshWallet();
  }

  Future<void> enqueueContribution({
    required String idempotencyKey,
    required String goalId,
    required int amountKobo,
    required String goalName,
  }) async {
    final available = await _balanceService.availableForNewActionsKobo();
    if (amountKobo > available) {
      throw MockApiException('Insufficient available balance');
    }

    await _api.updateGoalPending(goalId, amountKobo);
    await _api.addPendingTransaction(
      WalletTransaction(
        id: _uuid.v4(),
        title: 'Save: $goalName',
        amountKobo: -amountKobo,
        createdAt: DateTime.now(),
        type: TransactionType.contribution,
        isPending: true,
        idempotencyKey: idempotencyKey,
      ),
    );
    await _queueRepository.enqueue(
      OfflineQueueItem(
        id: _uuid.v4(),
        idempotencyKey: idempotencyKey,
        type: OfflineActionType.contributeGoal,
        payload: {
          'goalId': goalId,
          'amountKobo': amountKobo,
          'goalName': goalName,
        },
        status: OfflineActionStatus.pending,
        createdAt: DateTime.now(),
      ),
    );
    announceSyncState('Pending');
    await _refreshWallet();
  }

  Future<void> _refreshWallet() async {
    if (Get.isRegistered<WalletController>()) {
      await Get.find<WalletController>().refreshWallet();
    }
  }

  @visibleForTesting
  Future<void> recoverAndSync() => _bootstrapSync();
}
