import 'package:flutter/material.dart';
import 'package:untitled1/models/shop_item_model.dart';
import '../services/api_service.dart'; // Crée ce modèle pour mapper les données de l'API

class ShopService {
  final ApiService _apiService = ApiService();

  // Méthode pour récupérer les articles du shop depuis l'API
  Future<List<ShopItemModel>> getShopItems() async {
    try {
      final data = await _apiService.getRequest('get_shop_items.php'); // Remplace par ton fichier PHP
      List<ShopItemModel> items = [];
      for (var item in data) {
        items.add(ShopItemModel.fromJson(item)); // Mappe les données JSON dans des objets ShopItem
      }
      return items;
    } catch (e) {
      print("Erreur lors de la récupération des items du shop: $e");
      return [];
    }
  }

// Acheter un objet
  Future<void> purchaseItem(int userId, int itemId) async {
    try {
      final data = {'user_id': userId, 'item_id': itemId};
      await _apiService.postRequest('shop/purchase', data);  // Appel à postRequest pour effectuer un achat
    } catch (e) {
      throw Exception('Erreur lors de l\'achat de l\'objet: $e');
    }
  }
}
