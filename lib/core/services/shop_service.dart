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

// Méthode pour acheter un objet et l'ajouter à l'utilisateur
  Future<void> purchaseItem(int userId, int itemId) async {
    try {
      // Créer un objet avec les données nécessaires
      final data = {
        'action': 'insert_user_shop_item',  // Action pour l'insertion dans la table user_shop_item
        'user_id': userId,                  // ID de l'utilisateur
        'shop_item_id': itemId,             // ID de l'objet acheté
      };

      // Utiliser l'apiService pour envoyer les données en POST
      final response = await _apiService.postRequest('post_user_shop_item.php', data);

      // Vérification de la réponse
      if (response['success'] == "Objet ajouté à l'utilisateur") {
        print("Achat effectué avec succès !");
      } else {
        print("Erreur lors de l'achat : ${response['error']}");
      }
    } catch (e) {
      print("Erreur lors de la demande à l'API: $e");
    }
  }
}
