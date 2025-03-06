import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../viewmodels/user_view_model.dart';

class UserForm extends StatefulWidget {
  final UserViewModel viewModel;
  final UserModel? user;

  const UserForm({super.key, required this.viewModel, this.user});

  @override
  UserFormState createState() => UserFormState();
}

class UserFormState extends State<UserForm> {
  late TextEditingController pseudoController;

  @override
  void initState() {
    super.initState();
    pseudoController = TextEditingController(text: widget.user?.pseudo ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.user == null ? "Ajouter un utilisateur" : "Modifier l'utilisateur"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: pseudoController, decoration: const InputDecoration(labelText: "Pseudo")),
          const SizedBox(height: 8)
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () {
            if (pseudoController.text.isNotEmpty != null) {
              if (widget.user == null) {
                widget.viewModel.addUser(
                    pseudoController.text
                );
              } else {
                widget.viewModel.updateUser(
                  widget.user!.id,
                  pseudo: pseudoController.text
                );
              }
              Navigator.pop(context);
            }
          },
          child: Text(widget.user == null ? "Ajouter" : "Modifier"),
        ),
      ],
    );
  }
}