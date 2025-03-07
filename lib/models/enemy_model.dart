class EnemyModel {
  final int level;
  final String name;
  final int totalLife;

  EnemyModel({
    required this.level,
    required this.name,
    required this.totalLife,
  });

  factory EnemyModel.fromJson(Map<String, dynamic> json) {
    return EnemyModel(
      level: json['level'] ?? 1,
      name: json['name'] ?? 'Unknown Enemy',
      totalLife: json['total_life'] ?? 0,
    );
  }
}
