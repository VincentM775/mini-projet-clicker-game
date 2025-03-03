import 'package:intl/intl.dart';

class UserModel {
  final int id;
  final String pseudo;
  final int total_experience;
  final int id_ennemy;

  // Constructeur classique
  UserModel({
    required this.id,
    required this.pseudo,
    required this.total_experience,
    required this.id_ennemy,
  });

  /*
   * Un factory en Flutter est un constructeur particulier qui permet
   * de créer des objets en effectuant des traitements et
   * des vérifications supplémentaires sur les paramètres
   * avant l'instanciation de notre objet.
   * Ici, on convertit les données Json de notre api en objet User
   */
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_player'] ?? 0,
      pseudo: json['pseudo'] ?? 'Nom inconnu',
      total_experience: json['total_experience'] ?? 0,
      id_ennemy: json['id_ennemy'] ?? 0,
    );
  }

}