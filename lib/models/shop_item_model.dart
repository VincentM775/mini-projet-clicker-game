class ShopItemModel {
  final int id;
  final String name;
  final String description;
  final int price;
  final int temps;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.temps,
  });

  factory ShopItemModel.fromJson(Map<String, dynamic> json) {
    return ShopItemModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      temps: json['temps'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'temps': temps,
    };
  }
}
