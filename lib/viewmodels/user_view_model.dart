import 'package:flutter/material.dart';
import '../core/services/user_service.dart';
import '../models/user_model.dart';

class UserViewModel extends ChangeNotifier {
  final UserRequest _userRequest = UserRequest();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _error = '';

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
      _users = await _userRequest.getUserById(id) as List<UserModel>;

      // Utiliser addPostFrameCallback pour appeler notifyListeners après la construction du widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _isLoading = false;
        notifyListeners(); // Notifie les écouteurs après la fin du build
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners(); // Notifie les écouteurs après la fin du build, même en cas d'erreur
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
}
