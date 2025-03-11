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

  Future<void> purchaseItem(int userId, int itemId) async {
    try {
      // Créer un objet avec les données nécessaires pour l'achat
      final data = {
        'action': 'insert_user_shop_item',  // Action pour l'insertion dans la table user_shop_item
        'user_id': userId,                  // ID de l'utilisateur
        'shop_item_id': itemId,             // ID de l'objet acheté
      };

      // Utiliser l'apiService pour envoyer les données en POST pour insérer dans user_shop_item
      final response = await _apiService.postRequest('post_user_shop_item.php', data);

      // Vérification de la réponse après l'insertion
      if (response['success'] == "Objet ajouté à l'utilisateur") {
        print("Achat effectué avec succès !");

        // Après l'ajout, appliquer l'impact de l'item (par exemple, le boost d'XP)
        int updatedXp = await applyItemEffects(userId, itemId);

        // Mettre à jour l'XP de l'utilisateur dans la base de données
        final updateResponse = await _apiService.postRequest('post_user_xp.php', {
          'action': 'update_user_xp',
          'user_id': userId,
          'total_experience': updatedXp,
        });

        // Vérification de la mise à jour de l'XP
        if (updateResponse['success'] == "Experience mise à jour") {
          print("XP mis à jour : $updatedXp");
        } else {
          print("Erreur lors de la mise à jour de l'XP.");
        }
      } else {
        print("Erreur lors de l'achat : ${response['error']}");
      }
    } catch (e) {
      print("Erreur lors de la demande à l'API: $e");
    }

    // Supprimer l'item après utilisation
    await _apiService.postRequest('post_user_shop_item.php', {
      'action': 'remove_item',  // Action pour l'insertion dans la table user_shop_item
      'user_id': userId,        // ID de l'utilisateur
      'shop_item_id': itemId,
    });
  }

  // Fonction pour appliquer les effets de l'item acheté (par exemple, un boost d'XP)
  Future<int> applyItemEffects(int userId, int itemId) async {
    // Récupérer l'XP actuel de l'utilisateur
    final userResponse = await _apiService.postRequest('get_user_xp.php', {'user_id': userId});

    // Vérifie si la réponse contient bien 'total_experience'
    int currentXp = 0;
    if (userResponse != null && userResponse.containsKey('total_experience')) {
      currentXp = userResponse['total_experience'] ?? 0;
    } else {
      print("Erreur : 'total_experience' non trouvée dans la réponse.");
    }

    // Variables pour les effets (comme les multiplicateurs de dégâts ou XP)
    double damageMultiplier = 1.0;
    double xpMultiplier = 1.0;
    int xpBonus = 0;
    int upgradeCostReduction = 0;

    // Appliquer les effets en fonction de l'ID de l'item
    switch (itemId) {
      case 1: // Item 1: Double les dégâts de clics pendant 10 secondes
        damageMultiplier = 2.0;
        // Réinitialiser après 10 secondes
        Future.delayed(Duration(seconds: 10), () {
          damageMultiplier = 1.0; // Remettre à 1 après 10 secondes
        });
        break;

      case 2: // Item 2: Triple les dégâts pendant 5 secondes
        damageMultiplier = 3.0;
        // Réinitialiser après 5 secondes
        Future.delayed(Duration(seconds: 5), () {
          damageMultiplier = 1.0; // Remettre à 1 après 5 secondes
        });
        break;

      case 3: // Item 3: Gagne 50/100 XP supplémentaires pendant 15 secondes
        xpBonus = 50; // Bonus d'XP
        // Réinitialiser après 15 secondes
        Future.delayed(Duration(seconds: 15), () {
          xpBonus = 0; // Remettre à 0 après 15 secondes
        });
        break;

      case 4: // Item 4: Multiplie par 2 les XP reçus par l'auto-click pendant 10 secondes
        xpMultiplier = 2.0;
        // Réinitialiser après 10 secondes
        Future.delayed(Duration(seconds: 10), () {
          xpMultiplier = 1.0; // Remettre à 1 après 10 secondes
        });
        break;

      case 5: // Item 5: Réduit de 20% le coût des améliorations pendant 30 secondes
        upgradeCostReduction = 20; // Réduction de 20%
        // Réinitialiser après 30 secondes
        Future.delayed(Duration(seconds: 30), () {
          upgradeCostReduction = 0; // Remettre à 0 après 30 secondes
        });
        break;

      default:
        break;
    }

    // Appliquer les effets dans les autres actions du jeu, par exemple lors du clic ou du gain d'XP
    // Exemple de l'XP calculée : si l'XP est augmenté, applique les bonus
    currentXp += (xpBonus * xpMultiplier).toInt();

    // Retourner l'XP mis à jour
    return currentXp;
  }
}
