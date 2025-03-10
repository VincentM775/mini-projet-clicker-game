import 'dart:math';

class UpgradeModel {
  final int id;
  final String name;
  final String description;
  int cost;
  int level;  // Ajout du niveau de l'amélioration
  int costActual;

  UpgradeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.level,
    required this.costActual
  });

  factory UpgradeModel.fromJson(Map<String, dynamic> json) {
    return UpgradeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
      level: json['level'] ?? 1,  // On récupère le niveau depuis l'API
      costActual: json['cost'] * pow(2.1, json['level'] ?? 1).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
      'level': level,
      'costActual': costActual
    };
  }
}
