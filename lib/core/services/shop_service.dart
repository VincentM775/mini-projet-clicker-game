import 'package:flutter/material.dart';
import 'package:untitled1/models/shop_item_model.dart';
import 'package:untitled1/views/game_view.dart';
import '../services/api_service.dart'; 

class ShopService {
  final ApiService _apiService = ApiService();

  Future<List<ShopItemModel>> getShopItems() async {
    try {
      final data = await _apiService.getRequest('get_shop_items.php'); 
      List<ShopItemModel> items = [];
      for (var item in data) {
        items.add(ShopItemModel.fromJson(item)); 
      }
      return items;
    } catch (e) {
      print("Erreur lors de la récupération des items du shop: $e");
      return [];
    }
  }

  Future<void> purchaseItem(int userId, int itemId) async {
    try {
      final data = {
        'action': 'insert_user_shop_item',  
        'user_id': userId,                  
        'shop_item_id': itemId,             
      };

      final response = await _apiService.postRequest('post_user_shop_item.php', data);

      if (response['success'] == "Objet ajouté à l'utilisateur") {
        int updatedXp = await applyItemEffects(userId, itemId);
        final updateResponse = await _apiService.postRequest('post_user_xp.php', {
          'action': 'update_user_xp',
          'user_id': userId,
          'total_experience': updatedXp,
        });

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

    await _apiService.postRequest('post_user_shop_item.php', {
      'action': 'remove_item',  
      'user_id': userId,        
      'shop_item_id': itemId,
    });
  }

  Future<int> applyItemEffects(int userId, int itemId) async {
    final userResponse = await _apiService.postRequest('get_user_xp.php', {'user_id': userId});

    int currentXp = 0;
    if (userResponse != null && userResponse.containsKey('total_experience')) {
      currentXp = userResponse['total_experience'] ?? 0;
    } else {
      print("Erreur : 'total_experience' non trouvée dans la réponse.");
    }

    double damageMultiplier = 1.0;
    double xpMultiplier = 1.0;
    int xpBonus = 0;
    int upgradeCostReduction = 0;

    switch (itemId) {
      case 1: // Item 1: Double les dégâts de clics pendant 10 secondes
        if (GameView.totalExperience >= 100){
          GameView.nbrDegatsParClick *= 2;
          GameView.totalExperience -=100;
          Future.delayed(Duration(seconds: 10), () {
            GameView.nbrDegatsParClick = (GameView.nbrDegatsParClick / 2) as int;
          });
        }
        break;

      case 2: // Item 2: Triple les dégâts pendant 5 secondes
        if (GameView.totalExperience >= 200){
          GameView.nbrDegatsParClick *= 3;
          GameView.totalExperience -=200;
          Future.delayed(Duration(seconds: 5), () {
            GameView.nbrDegatsParClick = (GameView.nbrDegatsParClick / 3) as int;
          });
        }
        break;

      case 3: // Item 3: Gagne 50/100 XP supplémentaires pendant 15 secondes
        // Réinitialiser après 15 secondes
        if (GameView.totalExperience >= 150){
          GameView.gainExp *= 2;
          GameView.totalExperience -=150;
          Future.delayed(Duration(seconds: 15), () {
            GameView.gainExp = (GameView.gainExp / 2) as int;
          });
        }


        break;

      case 4: // Item 4: Multiplie par l'auto-click pendant 10 secondes
        if (GameView.totalExperience >= 250){
          GameView.nbrDegatsAutoClicker *= 2;
          GameView.totalExperience -=250;
          Future.delayed(Duration(seconds: 10), () {
            GameView.nbrDegatsAutoClicker = (GameView.nbrDegatsAutoClicker / 2) as int;
          });
        }
        break;

      default:
        break;
    }

    currentXp += (xpBonus * xpMultiplier).toInt();

    return currentXp;
  }
}
