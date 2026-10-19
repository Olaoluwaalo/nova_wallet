import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:nova/core/offline/offline_action_type.dart';
import 'package:nova/core/offline/offline_queue_item.dart';
import 'package:nova/features/wallet/domain/models/transaction_model.dart';
import 'package:nova/shared/widgets/transaction_tile.dart';

class WalletTransactionTileMapper {
  static TransactionTile fromTransaction(WalletTransaction transaction) {
    final type = switch (transaction.type) {
      TransactionType.send => TxTileType.sent,
      TransactionType.contribution => TxTileType.savings,
      TransactionType.credit => TxTileType.received,
    };
    final status = transaction.isPending ? TxTileStatus.pending : TxTileStatus.completed;
    final subtitle = DateFormat.MMMd().add_jm().format(transaction.createdAt);

    return TransactionTile(
      title: transaction.title,
      subtitle: subtitle,
      amountKobo: transaction.amountKobo,
      type: type,
      status: status,
      isCredit: transaction.type == TransactionType.credit,
    );
  }

  static TransactionTile fromFailedQueue(
    OfflineQueueItem item, {
    required VoidCallback onRetry,
  }) {
    final amount = item.payload['amountKobo'] as int;
    final title = switch (item.type) {
      OfflineActionType.sendMoney =>
        'Send to ${item.payload['recipientName'] ?? 'recipient'}',
      OfflineActionType.contributeGoal =>
        'Save to ${item.payload['goalName'] ?? 'goal'}',
    };
    final subtitle = item.errorMessage ?? 'Failed — tap retry';

    return TransactionTile(
      title: title,
      subtitle: subtitle,
      amountKobo: amount,
      type: item.type == OfflineActionType.sendMoney ? TxTileType.sent : TxTileType.savings,
      status: TxTileStatus.failed,
      onRetry: onRetry,
    );
  }
}
