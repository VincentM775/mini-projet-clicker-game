class ShopItemModel {
  final int id;
  final String name;
  final String description;
  final int cost;  // Le prix de l'objet en monnaie (par exemple, pièces, gemmes, etc.)

  ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
  });

  // Méthode de désérialisation pour convertir un JSON en un objet ShopItemModel
  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cost: json['cost'],
    );
  }

  // Méthode de sérialisation pour convertir un objet ShopItemModel en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cost': cost,
    };
  }
}
