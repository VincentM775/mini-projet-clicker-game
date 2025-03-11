import 'package:flutter/material.dart';
import '../core/services/enemy_service.dart';
import '../models/enemy_model.dart';

class EnemyViewModel extends ChangeNotifier {
  final EnemyService _enemyService = EnemyService();
  List<EnemyModel> _enemies = [];
  bool _isLoading = false;
  String _error = '';

  List<EnemyModel> get enemies => _enemies;
  bool get isLoading => _isLoading;
  String get errorMessage => _error;

  Future<void> fetchEnemies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _enemies = await _enemyService.getEnemies();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEnemyByLevel(int level) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      EnemyModel? enemy = await _enemyService.getEnemyByLevel(level);
      if (enemy != null) {
        _enemies = [enemy];
      } else {
        _enemies = [];
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

}
