import 'package:flutter/material.dart';
import '../views/game_view.dart';

import '../models/user_model.dart';

class UsersTable extends StatelessWidget {
  final List<UserModel> users;
  final Function(UserModel) onEdit;
  final Function(int) onDelete;

  const UsersTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  void _startGame(BuildContext context, int user) {
    // final gameViewModel = context.read<GameViewModel>();
    // gameViewModel.setGame(user);
    // gameViewModel.generateMap();// Configure la partie
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 20,
      columns: const [
        DataColumn(label: Text("Pseudo")),
        DataColumn(label: Text("Total expérience")),
        DataColumn(label: Text("dernier ennemi")),
        DataColumn(label: Text("Actions")),
        DataColumn(label: Text("")),

      ],
      rows: users.map((user) {
        return DataRow(cells: [
          DataCell(Text(user.pseudo)),
          DataCell(Text(user.total_experience.toString())),
          DataCell(Text(user.id_ennemy.toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(user),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onDelete(user.id),
              ),
            ],
          )),
          DataCell(Row(
            children: [
              IconButton(
                icon: const Row(
                  children: [
                    Text("Jouer avec cette utilisateur "),
                    Icon(Icons.start, color: Colors.blue),
                  ],
                )  ,
                onPressed: () => _startGame(context,user.id),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }
}