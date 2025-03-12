import 'package:flutter/material.dart';
import '../../models/upgrade_model.dart';
import '../services/api_service.dart';

class UpgradeService {
  final ApiService _apiService = ApiService();

  // Récupérer la liste des améliorations depuis l'API pour un utilisateur donné
  Future<List<UpgradeModel>> getUpgrades(int userId) async {
    try {
      final data = await _apiService.getRequest('get_upgrades.php?user_id=$userId');
      List<UpgradeModel> upgrades = data.map<UpgradeModel>((json) => UpgradeModel.fromJson(json)).toList();
      return upgrades;
    } catch (e) {
      print("Erreur lors de la récupération des améliorations: $e");
      return [];
    }
  }

  // Appliquer une amélioration à l'utilisateur
  Future<Map<String, dynamic>> applyUpgrade(int userId, int upgradeId) async {
  try {
    final data = {'user_id': userId, 'upgrade_id': upgradeId};
    final response = await _apiService.postRequest('post_upgrade.php', data);

    print("Réponse API applyUpgrade: $response");

    return response;
  } catch (e) {
    print("Erreur lors de l'application de l'amélioration: $e");
    return {'error': 'Une erreur est survenue'};
  }
}

}
