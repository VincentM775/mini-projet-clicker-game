import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class ApiService {

  final String baseUrl = Config.baseUrl;

  /*
    En passant par une requête HTTP, nos données sont dites asynchrones.
    On utilise Future pour retourner des données asynchrones.
    Ici, la fonction nous permet de récupérer des données par requete GET
   */
  Future<dynamic> getRequest(String fichierPhp, {Map<String, String>? queryParams}) async {

    //On déclare l'URL de notre API à appeler pour la récupération de nos données en base.
    Uri url = Uri.parse('$baseUrl/$fichierPhp').replace(queryParameters: queryParams);

    // Avec await, on attend le retour de réponse de notre requête avant de poursuivre l'exécution du code.
    final response = await http.get(url);

    // Si le code d'état HTTP envoyé par le serveur est 200 (= succès de l'opération)
    if (response.statusCode == 200) {
      //On décode la réponse JSON en une liste dynamique (ici une liste d'objets json) de données.
      // jsonDecode permet de convertir une réponse JSON en objet Dart.
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }

  /*
  * Fonction qui permet de gérer les requêtes POST
  */
  Future<dynamic> postRequest(String fichierPhp, Map<String, dynamic> data) async {
    Uri url = Uri.parse('$baseUrl/$fichierPhp');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur serveur: ${response.statusCode}');
    }
  }
}