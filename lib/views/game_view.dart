import 'package:flutter/material.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Démarre l'animation d'attaque
    _controller.forward(from: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          // Partie gauche (fond beige)
          Expanded(
            flex: 1, // 50% de l'écran
            child: Container(
              color: Colors.brown, // Fond beige
            ),
          ),
          // Partie droite (Image cliquable + compteur)
          Expanded(
            flex: 1, // 50% de l'écran
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Compteur
                Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Image cliquable avec effet d'attaque
                GestureDetector(
                  onTap: _incrementCounter,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/1.webp', // Remplace avec ton image
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
