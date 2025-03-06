import '../../models/user_model.dart';
import 'api_service.dart';

class UserRequest {
  final ApiService apiService = ApiService();

  /*---------------------*/
  /* Lectures de données */
  /*---------------------*/

  /*
  * Cette fonction permet de récupérer la liste complète des users
  */
  Future<List<UserModel>> getUsers() async {
    List<dynamic> data = await apiService.getRequest("get_users.php");
    return data.map((user) => UserModel.fromJson(user)).toList();
  }

  /*
  * Cette fonction permet de récupérer un utilisateur par son id
  */
  Future<UserModel?> getUserById(int id) async {
    Map<String, String> queryParams = {"id_player": id.toString()};
    List<dynamic> data =
        await apiService.getRequest("get_users.php", queryParams: queryParams);
    if (data.isNotEmpty) {
      return UserModel.fromJson(data.first);
    }
    return null;
  }

  /*
  * Cette fonction permet de récupérer un utilisateur par son nom
  */
  Future<List<UserModel>> getUserByLastname(String pseudo) async {
    Map<String, String> queryParams = {"pseudo": Uri.encodeComponent(pseudo)};
    List<dynamic> data =
        await apiService.getRequest("get_users.php", queryParams: queryParams);
    return data.map((user) => UserModel.fromJson(user)).toList();
  }

  /*
   * Cette fonction est un exemple de récupération de données multi-filtre
   */
  Future<List<UserModel>> getUsersByFilters({String? pseudo}) async {
    Map<String, String> queryParams = {};
    if (pseudo != null) queryParams['pseudo'] = Uri.encodeComponent(pseudo);

    List<dynamic> data =
        await apiService.getRequest("get_users.php", queryParams: queryParams);
    return data.map((userData) => UserModel.fromJson(userData)).toList();
  }

  /*---------------------*/
  /* Ecriture de données */
  /*---------------------*/

  // Cette méthode permet d'ajouter un nouvel utilisateur à la base
  Future<void> insertUser(String pseudo) async {
    await apiService
        .postRequest("post_users.php", {"action": "insert", "pseudo": pseudo});
  }

  // Cette méthode permet de modifier un utilisateur par son id.
  Future<void> updateUser(int id, {String? pseudo}) async {
    Map<String, dynamic> data = {
      "action": "update",
      "id_player": id.toString(),
    };
    if (pseudo != null) data["pseudo"] = pseudo;

    await apiService.postRequest("post_users.php", data);
  }

  // Cette méthode permet de supprimer un utilisateur par son id.
  Future<void> deleteUser(int id) async {
    await apiService.postRequest("post_users.php", {
      "action": "delete",
      "id_player": id.toString(),
    });
  }

  Future<void> updateUserTotalExperience(int id, int newTotalExperience) async {
  try {
    // Log de débogage pour suivre les valeurs envoyées
    print("Je passe par là");
    print(id.toString() + " " + newTotalExperience.toString());

    // Envoie la requête à l'API pour mettre à jour l'expérience du joueur
    final response = await apiService.postRequest("post_users.php", {
      "action": "update_total_experience",
      "id_player": id.toString(),
      "total_experience": newTotalExperience.toString(),
    });

    // Vérifie si la réponse est correcte et affiche un log
    if (response['success'] != null) {
      print("Mise à jour réussie de l'expérience !");
    } else {
      print("Erreur lors de la mise à jour : ${response['message']}");
    }
  } catch (e) {
    print("Erreur : $e");
  }
}

}
