
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/user_model.dart';
import '../widgets/form/user_form.dart';
import '../widgets/users_table.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  // Un controller permet de suivre instantannément les changements dans un input.
  // Celui-ci est utilisé pour la barre de recherche.
  // on peut notamment récupérer le texte saisit grâce à lui (ex. _searchController.text)
  final TextEditingController _searchController = TextEditingController();

  // Méthode qui est appelée qu'une seule fois lorsque l'instance du widget est insérée dans l'arbre.
  // propre à un widget stateful
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserViewModel>(context, listen: false).fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilisateurs'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<UserViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              // C'est l'animation du loader
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.errorMessage.isNotEmpty) {
              return Center(child: Text(viewModel.errorMessage));
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de recherche
                  TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: "Chercher un utilisateur",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => viewModel.filterUsers(value), // à chaque changement dans la barre de recherche
                  ),

                  const SizedBox(height: 30), //espacement vertical entre les widgets

                  // Bouton Ajouter
                  ElevatedButton.icon(
                    onPressed: () => _showUserForm(context, viewModel),
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter un utilisateur"),
                  ),

                  const SizedBox(height: 30),

                  // Liste des utilisateurs
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: UsersTable(
                        users: viewModel.filteredUsers,
                        onEdit: (user) => _showUserForm(context, viewModel, user: user),
                        onDelete: (userId) => _confirmDelete(context, viewModel, userId),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  // Modale pour ajouter / modifier un utilisateur
  void _showUserForm(BuildContext context, UserViewModel viewModel, {UserModel? user}) {
    showDialog(
      context: context,
      builder: (context) {
        return UserForm(viewModel: viewModel, user: user);
      },
    );
  }

  // Modale de confirmation pour supprimer un utilisateur
  void _confirmDelete(BuildContext context, UserViewModel viewModel, int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Supprimer l'utilisateur"),
          content: const Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                viewModel.deleteUser(userId);
                Navigator.pop(context);
              },
              child: const Text("Supprimer"),
            ),
          ],
        );
      },
    );
  }
}