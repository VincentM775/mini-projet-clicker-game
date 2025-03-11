import 'dart:math';

class UpgradeModel {
  final int id;
  final String name;
  final String description;
  final int cost;
  final int level;
  final int costActual;

  UpgradeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.level,
    required this.costActual,
  });

  factory UpgradeModel.fromJson(Map<String, dynamic> json) {
    int level = json['level'] ?? 1;
    return UpgradeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
      level: level,
      costActual: (json['cost'] * pow(2.1, level)).round(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'level': level,
      'costActual': costActual,
    };
  }

  /// 🔹 Ajoute cette méthode pour créer une copie avec des valeurs modifiées
  UpgradeModel copyWith({int? level, int? costActual}) {
    return UpgradeModel(
      id: id,
      name: name,
      description: description,
      cost: cost,
      level: level ?? this.level,
      costActual: costActual ?? this.costActual,
    );
  }
}
