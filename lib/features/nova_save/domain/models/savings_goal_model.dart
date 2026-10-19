class SavingsGoal {
  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetKobo,
    required this.savedKobo,
    required this.targetDate,
    this.pendingContributionKobo = 0,
  });

  final String id;
  final String name;
  final int targetKobo;
  final int savedKobo;
  final DateTime targetDate;
  final int pendingContributionKobo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetKobo': targetKobo,
        'savedKobo': savedKobo,
        'targetDate': targetDate.toIso8601String(),
        'pendingContributionKobo': pendingContributionKobo,
      };

  factory SavingsGoal.fromJson(Map<dynamic, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      name: json['name'] as String,
      targetKobo: json['targetKobo'] as int,
      savedKobo: json['savedKobo'] as int,
      targetDate: DateTime.parse(json['targetDate'] as String),
      pendingContributionKobo: json['pendingContributionKobo'] as int? ?? 0,
    );
  }

  SavingsGoal copyWith({
    int? savedKobo,
    int? pendingContributionKobo,
  }) {
    return SavingsGoal(
      id: id,
      name: name,
      targetKobo: targetKobo,
      savedKobo: savedKobo ?? this.savedKobo,
      targetDate: targetDate,
      pendingContributionKobo: pendingContributionKobo ?? this.pendingContributionKobo,
    );
  }
}
