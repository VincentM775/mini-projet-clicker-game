import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_model.dart';
import '../viewmodels/user_view_model.dart';

class GameView extends StatefulWidget {
  final int userId; // Ajoute cette variable pour recevoir l'id
  const GameView({super.key, required this.userId});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
  late UserModel _user;  // Variable pour stocker les infos de l'utilisateur
  bool _isLoading = true;

  int _counter = 0; // Compteur
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Durée de l'effet
      lowerBound: 0.9, // Réduction à 90% de la taille
      upperBound: 1.0, // Retour à la taille normale
    );

    _scaleAnimation = _controller.drive(CurveTween(curve: Curves.easeOut));
    _user = UserModel(id: 0, pseudo: 'Inconnu', total_experience: 0, id_ennemy: 0, nbr_mort_dern_ennemi: 0); // Initialiser _user
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final userViewModel = Provider.of<UserViewModel>(context, listen: false);
  await userViewModel.fetchUserById(widget.userId);
  setState(() {
    _user = userViewModel.users.firstWhere((user) => user.id == widget.userId, orElse: () => UserModel(id: 0, pseudo: 'Inconnu', total_experience: 0, id_ennemy: 0, nbr_mort_dern_ennemi: 0));
    _counter = _user.total_experience;
    _isLoading = false;
  });
}

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() async {
    setState(() {
      _counter++;
    });

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    await userViewModel.updateUserTotalExperience(widget.userId, _counter);

    _controller.forward(from: 0.9);
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
                        'Expérience : ${_user.total_experience}',
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
                Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _incrementCounter,
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
