class SendPendingArgs {
  const SendPendingArgs({
    required this.amountKobo,
    required this.recipientName,
    required this.idempotencyKey,
  });

  final int amountKobo;
  final String recipientName;
  final String idempotencyKey;
}
