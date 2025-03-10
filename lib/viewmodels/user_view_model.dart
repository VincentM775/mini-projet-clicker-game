import 'package:flutter/material.dart';
import '../core/services/upgrade_service.dart';
import '../core/services/user_service.dart';
import '../models/user_model.dart';


class UserViewModel extends ChangeNotifier {
  final UserRequest _userRequest = UserRequest();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _error = '';
  final UpgradeService _upgradeService = UpgradeService();  // Service d'amélioration

  UserModel? _user;
  UserModel? get user => _user;


  List<UserModel> get users => _users;

  bool get isLoading => _isLoading;
  String get errorMessage => _error;

  List<UserModel> _filteredUsers = [];
  List<UserModel> get filteredUsers => _filteredUsers;

  /*---------------------*/
  /* Lectures de données */
  /*---------------------*/
  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _userRequest.getUsers();
      _filteredUsers = List.from(_users);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUserById(int id) async {
    _isLoading = true;
    _error = '';

    try {
      _user = await _userRequest.getUserById(id); // Supposé retourner UN utilisateur
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }


  Future<void> fetchUsersByLastname(String pseudo) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _users = await _userRequest.getUserByLastname(pseudo);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      _filteredUsers = _users
          .where((user) =>
              user.pseudo.toLowerCase().contains(query.toLowerCase()) ||
              user.pseudo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  /*---------------------*/
  /* Ecriture de données */
  /*---------------------*/

  Future<void> addUser(String pseudo) async {
    try {
      await _userRequest.insertUser(pseudo);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateUser(int id, {String? pseudo}) async {
    try {
      await _userRequest.updateUser(id, pseudo: pseudo);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    try {
      await _userRequest.deleteUser(id);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> updateUserTotalExperience(int id, int newTotalExperience) async {
    try {
      await _userRequest.updateUserTotalExperience(id, newTotalExperience);
      await fetchUserById(id);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  // Méthode pour mettre à jour l'id de l'ennemi
  Future<void> updateIdEnnemi(int id, int newIdEnnemi) async {
    try {
      await _userRequest.updateIdEnnemi(id, newIdEnnemi);
      notifyListeners();  // Notifie les abonnés si nécessaire
    } catch (e) {
      print("Erreur dans UserViewModel lors de la mise à jour de id_ennemy : $e");
    }
  }

  // Méthode pour mettre à jour le nombre de morts du dernier ennemi
  Future<void> updateNbrMortDernEnnemi(int id, int newNbrMortDernEnnemi) async {
    try {
      await _userRequest.updateNbrMortDernEnnemi(id, newNbrMortDernEnnemi);
      notifyListeners();  // Notifie les abonnés si nécessaire
    } catch (e) {
      print("Erreur dans UserViewModel lors de la mise à jour de nbr_mort_dern_ennemi : $e");
    }
  }

}
