import 'package:nova/core/offline/offline_action_status.dart';
import 'package:nova/core/offline/offline_action_type.dart';

class OfflineQueueItem {
  const OfflineQueueItem({
    required this.id,
    required this.idempotencyKey,
    required this.type,
    required this.payload,
    required this.status,
    required this.createdAt,
    this.errorMessage,
  });

  final String id;
  final String idempotencyKey;
  final OfflineActionType type;
  final Map<String, dynamic> payload;
  final OfflineActionStatus status;
  final DateTime createdAt;
  final String? errorMessage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'idempotencyKey': idempotencyKey,
        'type': type.name,
        'payload': payload,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'errorMessage': errorMessage,
      };

  factory OfflineQueueItem.fromJson(Map<dynamic, dynamic> json) {
    return OfflineQueueItem(
      id: json['id'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      type: OfflineActionType.values.byName(json['type'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      status: OfflineActionStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      errorMessage: json['errorMessage'] as String?,
    );
  }

  OfflineQueueItem copyWith({
    OfflineActionStatus? status,
    String? errorMessage,
  }) {
    return OfflineQueueItem(
      id: id,
      idempotencyKey: idempotencyKey,
      type: type,
      payload: payload,
      status: status ?? this.status,
      createdAt: createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
