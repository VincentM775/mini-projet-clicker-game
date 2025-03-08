
import '../../models/user_model.dart';
import 'api_service.dart';

class UpgradeService {
  final ApiService apiService = ApiService();

  // Fonction pour multiplier les points de clic par 10 (et l'envoyer au backend si nécessaire)
  Future<void> multiplyClickPointsBy10(UserModel user) async {
    try {
      // Exemple d'appel API pour mettre à jour le total d'expérience
      Map<String, dynamic> data = {
        'userId': user.id,
        'experience': user.total_experience * 10,
      };

      // Effectuer la requête POST pour mettre à jour l'expérience
      var response = await apiService.postRequest('updateExperience.php', data);

      if (response['status'] == 'success') {
        user.total_experience = response['newExperience'];  // Mise à jour des données utilisateur avec la réponse de l'API
      } else {
        throw Exception('Erreur lors de la mise à jour des points');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Erreur de communication avec le serveur');
    }
  }

  // Fonction pour activer l'autoclicker (et envoyer cette information au backend)
  Future<void> enableAutoClicker(UserModel user) async {
    try {
      // Exemple d'appel API pour activer un autoclicker
      Map<String, dynamic> data = {
        'userId': user.id,
        'autoClickerEnabled': true,
      };

      // Effectuer la requête POST pour activer l'autoclicker
      var response = await apiService.postRequest('enableAutoClicker.php', data);

      if (response['status'] == 'success') {
        user.autoClickerEnabled = true;  // Mise à jour des données utilisateur avec la réponse de l'API
      } else {
        throw Exception('Erreur lors de l\'activation de l\'autoclicker');
      }
    } catch (e) {
      print('Erreur API: $e');
      throw Exception('Erreur de communication avec le serveur');
    }
  }
}