import '../../models/enemy_model.dart';
import 'api_service.dart';

class EnemyService {
  final ApiService apiService = ApiService();

  /*---------------------*/
  /* 📌 LECTURE DES DONNÉES */
  /*---------------------*/

  // Récupère la liste complète des ennemis
  Future<List<EnemyModel>> getEnemies() async {
    List<dynamic> data = await apiService.getRequest("get_enemies.php");
    return data.map((enemy) => EnemyModel.fromJson(enemy)).toList();
  }

  // Récupère un ennemi par son niveau (ID)
  Future<EnemyModel?> getEnemyByLevel(int level) async {
    Map<String, String> queryParams = {"level": level.toString()};
    List<dynamic> data =
        await apiService.getRequest("get_enemies.php", queryParams: queryParams);
    if (data.isNotEmpty) {
      return EnemyModel.fromJson(data.first);
    }
    return null;
  }
}
