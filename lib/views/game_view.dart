import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/views/home_view.dart';
import '../viewmodels/game_view_model.dart';
// import '../widgets/map_button.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  void _backMenu(BuildContext context) {
    // final gameViewModel = context.read<GameViewModel>();
    // gameViewModel.setGame(user);
    // gameViewModel.generateMap();// Configure la partie
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeView()),
    );
  }


  @override
  Widget build(BuildContext context) {
    // final gameViewModel = context.watch<GameViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clicker Game',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _backMenu(context);
            },
          ),
        ],
      ),
      body: Text("Helloo, tu es sur la deuxième page")
    );
  }

}
