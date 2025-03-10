import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/services/api_service.dart';
import '../models/user_model.dart';
import '../viewmodels/user_view_model.dart';
import '../core/services/enemy_service.dart';
import '../models/enemy_model.dart';

class GameView extends StatefulWidget {
  final int userId;
  const GameView({super.key, required this.userId});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late UserModel _user;
  EnemyModel? _enemy;
  bool _isLoading = true;

  int _totalExperience = 0;
  int _nbrVieRestant = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _currentLife = 1.0;  // Représente le pourcentage de vie restant (1.0 = 100%)
  int _totalLife = 1; // Vie maximale de l'ennemi


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _user = UserModel(
      id: 0,
      pseudo: 'Inconnu',
      total_experience: 0,
      id_ennemy: 0,
      nbr_mort_dern_ennemi: 0,
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    await userViewModel.fetchUserById(widget.userId);

    setState(() {
      _user = userViewModel.user ?? UserModel(
        id: 1,
        pseudo: 'Inconnu',
        total_experience: 0,
        id_ennemy: 1,
        nbr_mort_dern_ennemi: 0,
      );

      _totalExperience = _user.total_experience;
      _loadEnemyData();
      _isLoading = false;
    });
  }

  Future<void> _loadEnemyData() async {
    final enemyService = EnemyService();
    try {
      final enemy = await enemyService.getEnemyByLevel(_user.id_ennemy);
      if (enemy != null) {
        setState(() {
          _enemy = enemy;
          _nbrVieRestant = enemy.totalLife;
          _totalLife = enemy.totalLife;  // Stocke la vie max pour la barre de vie
          _currentLife = 1.0;  // Réinitialisation de la barre de vie
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'ennemi : $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decrementCounter() async {
    if (_nbrVieRestant > 0) {
      setState(() {
        _nbrVieRestant--;
        _currentLife = _nbrVieRestant / _totalLife;  // Met à jour la barre de vie
      });

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.updateUserTotalExperience(widget.userId, _totalExperience + 1);

      if (_nbrVieRestant == 0) {
        _levelUp();
      }

      _controller.forward(from: 0.9);
    }
  }

  void _levelUp() async {
    setState(() {
      _totalExperience += 1 * _user.id_ennemy; // Ajoute de l'expérience en montant de niveau

      if (_user.nbr_mort_dern_ennemi >= 10) {
        _user = UserModel(
          id: _user.id,
          pseudo: _user.pseudo,
          total_experience: _user.total_experience,
          id_ennemy: _user.id_ennemy + 1,  // Mise à jour du niveau de l'ennemi
          nbr_mort_dern_ennemi: 0,         // Réinitialisation du nombre de morts
        );

        // Mise à jour du niveau de l'ennemi via le UserViewModel
        final userViewModel = Provider.of<UserViewModel>(context, listen: false);
        userViewModel.updateIdEnnemi(_user.id, _user.id_ennemy);  // Mise à jour de l'id_ennemy
      } else {
        _user = UserModel(
          id: _user.id,
          pseudo: _user.pseudo,
          total_experience: _user.total_experience,
          id_ennemy: _user.id_ennemy,  // Reste le même
          nbr_mort_dern_ennemi: _user.nbr_mort_dern_ennemi + 1, // Incrémentation des morts
        );

        // Mise à jour du nombre de morts du dernier ennemi via le UserViewModel
        final userViewModel = Provider.of<UserViewModel>(context, listen: false);
        userViewModel.updateNbrMortDernEnnemi(_user.id, _user.nbr_mort_dern_ennemi);
      }
    });

    await _loadEnemyData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          iconSize: 30,
          alignment: Alignment.centerLeft,
          splashRadius: 20,
          enableFeedback: true,
          focusColor: Colors.white,
          highlightColor: Colors.white,
          splashColor: Colors.white,
          mouseCursor: SystemMouseCursors.click,
        ),
        title: const Text(
          'Clicker Game',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.brown,
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Pseudo : ${_user.pseudo}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        'Expérience : $_totalExperience',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/enemies/background.webp',
                      fit: BoxFit.cover,
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Niveau actuel : ${_user.id_ennemy}',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Nombre de mort avant prochain niveau : ${_user.nbr_mort_dern_ennemi}/10',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          '$_nbrVieRestant',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _decrementCounter,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Image.asset(
                              'assets/enemies/1.webp',
                              width: 150,
                              height: 150,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Niveau actuel : ${_user.id_ennemy}',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Nombre de mort avant prochain niveau : ${_user.nbr_mort_dern_ennemi}/10',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),


                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Stack(
                    alignment: Alignment.center, // Centre le texte sur la barre
                    children: [
                      SizedBox(
                        height: 20, // Augmente la hauteur pour une meilleure visibilité
                        child: LinearProgressIndicator(
                          value: _currentLife, // Valeur dynamique entre 0.0 et 1.0
                          backgroundColor: Colors.red[200], // Couleur de fond
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Couleur de la vie restante
                          minHeight: 20, // Ajuste la hauteur
                        ),
                      ),
                      Text(
                        '$_nbrVieRestant / $_totalLife', // Affichage des PV restants
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Assure une bonne visibilité
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _decrementCounter,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/1.webp',
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
