import 'package:flutter/material.dart';
import '../../models/upgrade_model.dart'; // Import du modèle d'amélioration
import '../services/api_service.dart';   // Service API pour effectuer les requêtes

class UpgradeService {
  final ApiService _apiService = ApiService(); // Instance de ApiService pour communiquer avec l'API

  // Récupérer la liste des améliorations depuis l'API
  Future<List<UpgradeModel>> getUpgrades() async {
    try {
      final data = await _apiService.getRequest('get_upgrades.php');  // Appel à l'API pour récupérer les améliorations
      List<UpgradeModel> upgrades = [];  // Liste pour stocker les améliorations
      for (var upgrade in data) {
        upgrades.add(UpgradeModel.fromJson(upgrade));  // Mapper les données JSON dans des objets UpgradeModel
      }
      return upgrades;  // Retourner la liste des améliorations
    } catch (e) {
      print("Erreur lors de la récupération des améliorations: $e");
      return [];  // Retourner une liste vide en cas d'erreur
    }
  }

  // Appliquer une amélioration à l'utilisateur
  Future<void> applyUpgrade(int userId, int upgradeId) async {
    try {
      final data = {'user_id': userId, 'upgrade_id': upgradeId};  // Paramètres pour l'amélioration
      await _apiService.postRequest('apply_upgrade', data);  // Appel à l'API pour appliquer l'amélioration
    } catch (e) {
      throw Exception('Erreur lors de l\'application de l\'amélioration: $e');
    }
  }
}
