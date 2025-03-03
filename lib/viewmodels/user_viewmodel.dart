import 'package:flutter/material.dart';
import '../core/services/user_service.dart';
import '../models/user_model.dart';
class UserViewModel extends ChangeNotifier {
  final UserRequest _userRequest = UserRequest();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _error = '';

  List<UserModel> get users => _users;

  // La variable isLoading nous permet de mettre un état de chargement de nos données en attendant qu'elles s'affichent.
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
    notifyListeners();

    try {
      _users = await _userRequest.getUserById(id) as List<UserModel>;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
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

  /* Méthode qui permet d'insérer des données en base */
  Future<void> addUser(String pseudo) async {
    try {
      await _userRequest.insertUser(pseudo);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  /* Méthode qui permet de modifier des données en base */
  Future<void> updateUser(int id, {String? pseudo}) async {
    try {
      await _userRequest.updateUser(id, pseudo: pseudo);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  /* Méthode qui permet de supprimer des données en base */
  Future<void> deleteUser(int id) async {
    try {
      await _userRequest.deleteUser(id);
      await fetchUsers();
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}