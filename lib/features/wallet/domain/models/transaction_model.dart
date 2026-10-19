enum TransactionType { send, contribution, credit }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.title,
    required this.amountKobo,
    required this.createdAt,
    required this.type,
    this.isPending = false,
    this.idempotencyKey,
  });

  final String id;
  final String title;
  final int amountKobo;
  final DateTime createdAt;
  final TransactionType type;
  final bool isPending;
  final String? idempotencyKey;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amountKobo': amountKobo,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
        'isPending': isPending,
        'idempotencyKey': idempotencyKey,
      };

  factory WalletTransaction.fromJson(Map<dynamic, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amountKobo: json['amountKobo'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: TransactionType.values.byName(json['type'] as String),
      isPending: json['isPending'] as bool? ?? false,
      idempotencyKey: json['idempotencyKey'] as String?,
    );
  }

  WalletTransaction copyWith({
    bool? isPending,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id,
      title: title,
      amountKobo: amountKobo,
      createdAt: createdAt ?? this.createdAt,
      type: type,
      isPending: isPending ?? this.isPending,
      idempotencyKey: idempotencyKey,
    );
  }
}
