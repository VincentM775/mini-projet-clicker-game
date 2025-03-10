class UpgradeModel {
  final int id;
  final String name;
  final String description;
  final int cost;  // Le coût de l'amélioration (par exemple en XP)

  UpgradeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

  // Méthode de désérialisation pour convertir un JSON en un objet UpgradeModel
  factory UpgradeModel.fromJson(Map<String, dynamic> json) {
    return UpgradeModel(
      id: json['id'],  // Assure-toi que les clés JSON correspondent aux noms des propriétés
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
    );
  }

  // Méthode de sérialisation pour convertir un objet UpgradeModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
    };
  }
}
