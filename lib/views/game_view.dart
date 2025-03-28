import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/core/services/upgrade_service.dart';
import 'package:untitled1/models/shop_item_model.dart';
import 'package:untitled1/models/upgrade_model.dart';

import '../core/services/api_service.dart';
import '../core/services/shop_service.dart';
import '../models/user_model.dart';
import '../viewmodels/user_view_model.dart';
import '../core/services/enemy_service.dart';
import '../models/enemy_model.dart';

class GameView extends StatefulWidget {
  final int userId;

  static int nbrDegatsParClick = 1;
  static int totalExperience = 0;
  static int gainExp = 1;
  static int nbrDegatsAutoClicker=0;



  const GameView({super.key, required this.userId});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView>
    with SingleTickerProviderStateMixin {
  late UserModel _user;
  EnemyModel? _enemy;
  bool _isLoading = true;

  int _nbrVieRestant = 0;
  Timer? _autoClickerTimer;
  bool _isAutoClickerActive = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  double _currentLife =
      1.0; // Représente le pourcentage de vie restant (1.0 = 100%)
  int _totalLife = 1; // Vie maximale de l'ennemi

  bool _isShowUpgradePanel = false;
  bool _isShowShopPanel = false;

  List<UpgradeModel> ameliorations = []; // Liste des améliorations
  List<ShopItemModel> shopItems = []; // Liste des items du shop

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    );

    _scaleAnimation = _controller.drive(CurveTween(curve: Curves.easeInSine));
    _user = UserModel(
      id: 0,
      pseudo: 'Inconnu',
      total_experience: 0,
      id_ennemy: 0,
      nbr_mort_dern_ennemi: 0,
    );
    _loadUserData();
  }

  Future<void> _loadAutoClicke() async {
    final upgradeService = UpgradeService();

    final ameliorationList = await upgradeService.getUpgrades(_user.id);
    print("lalala : ${ameliorationList[1].level }");
    if(ameliorationList[1].level >=1) {
      ameliorations = ameliorationList;
      GameView.nbrDegatsAutoClicker = pow(2, ameliorations[1].level-1).toInt();
      _startAutoClicker();
      print("AUTOCLICKER COMMENCER nouvelle valeur de nbrdegatparclick : ${GameView.nbrDegatsAutoClicker}");

    }else{
      print("je ne rentre pas la");
    }
  }

  Future<void> _loadUserData() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    await userViewModel.fetchUserById(widget.userId);

    setState(() {
      _user = userViewModel.user ??
          UserModel(
            id: 1,
            pseudo: 'Inconnu',
            total_experience: 0,
            id_ennemy: 1,
            nbr_mort_dern_ennemi: 0,
          );

      GameView.totalExperience = _user.total_experience;
      _loadEnemyData();
      _isLoading = false;
    });
  }

  Future<void> _loadEnemyData() async {
    final enemyService = EnemyService();
    try {
      final enemy = await enemyService.getEnemyByLevel(_user.id_ennemy);
      if (enemy != null && !(_user.id_ennemy == 30 && _user.nbr_mort_dern_ennemi >= 1)) {
        setState(() {
          _enemy = enemy;
          _nbrVieRestant = enemy.totalLife;
          _totalLife =
              enemy.totalLife; // Stocke la vie max pour la barre de vie
          _currentLife = 1.0; // Réinitialisation de la barre de vie
        });
      }else {
        showDialog(
          context: context,
          barrierDismissible: false, // Empêche de fermer en cliquant à l'extérieur
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Félicitations !"),
              content: const Text("Le jeu est terminé, bravo !"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le pop-up
                    Navigator.of(context).pop(); // Retourne à l'écran précédent
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }

    } catch (e) {
      print('Erreur lors du chargement de l\'ennemi : $e');
    }
  }

  void _showUpgradePanel() async {
    final upgradeService = UpgradeService();
    try {
      final ameliorationList = await upgradeService.getUpgrades(_user.id);
      setState(() {
        ameliorations = ameliorationList;
        GameView.nbrDegatsParClick = pow(2,ameliorations[0].level).toInt();
      });
      print("nouvelle valeur de nbrdegatparclick : ${GameView.nbrDegatsParClick}");
    } catch (e) {
      print("Erreur lors du chargement des améliorations: $e");
    }
    _loadAutoClicke();

  }

  void _showShopPanel() async {
    final shopService = ShopService();
    try {
      final items = await shopService.getShopItems();
      setState(() {
        shopItems = items
            .map((item) => item)
            .toList(); // Mettre à jour la liste des items du shop
      });
    } catch (e) {
      print("Erreur lors du chargement du shop: $e");
    }
  }

  void _purchaseItem(ShopItemModel item) async {
    final shopService = ShopService();
    try {
      await shopService.purchaseItem(
          _user.id, item.id); // Effectuer l'achat via l'API
      setState(() {
        // Update the XP to reflect the change
      });

      print("Achat effectué avec succès ! XP mis à jour à: $_user.total_experience");

    } catch (e) {
      print("Erreur lors de l'achat: $e");
    }
  }

  void _applyUpgrade(int upgradeId) async {
  final upgradeService = UpgradeService();
  try {
    final result = await upgradeService.applyUpgrade(_user.id, upgradeId);
    if (result.containsKey('error')) {
      print(result['error']);
      return;
    }

    print("Résultat après amélioration: $result");

    setState(() {
      GameView.totalExperience = result['new_xp'] ?? GameView.totalExperience;

      ameliorations = ameliorations.map((amelioration) {
        if (amelioration.id == upgradeId) {
          return amelioration.copyWith(
            level: amelioration.level + 1,
            costActual: (amelioration.cost * pow(2.1, amelioration.level + 1)).round(),
          );
        }
        return amelioration;
      }).toList();


      if (upgradeId == 2) {
        GameView.nbrDegatsAutoClicker = pow(2, ameliorations[1].level - 1).toInt();
        _startAutoClicker();
      }
      else if (upgradeId == 1) {
        GameView.nbrDegatsParClick = pow(2, ameliorations[0].level).toInt();
      }
    });
  } catch (e) {
    print("Erreur lors de l'amélioration: $e");
  }
}

void _startAutoClicker() {
  if (_isAutoClickerActive) return;

  _isAutoClickerActive = true;
  print("AutoClicker activé : $GameView.nbrDegatsAutoClicker clics/sec");

  _autoClickerTimer?.cancel();

  _autoClickerTimer = Timer.periodic(Duration(milliseconds: (1000 / GameView.nbrDegatsAutoClicker).round()), (timer) {
    setState(() {
      _decrementCounterAutoclicker();
    });

    print("Auto-click effectué ! vie restant a l'ennemi: $_nbrVieRestant");
  });
}

  void _stopAutoClicker() {
    _autoClickerTimer?.cancel();
    _isAutoClickerActive = false;
    print("AutoClicker désactivé !");
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _decrementCounter() async {
    if (_nbrVieRestant > 0) {
      setState(() {
        _nbrVieRestant-=GameView.nbrDegatsParClick;
        if (_nbrVieRestant <0){
          _nbrVieRestant = 0;
        }
        _currentLife = _nbrVieRestant / _totalLife;
      });

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.updateUserTotalExperience(
          widget.userId, GameView.totalExperience + 1);

      if (_nbrVieRestant <= 0) {
        _levelUp();
      }

      _controller.forward(from: 0.9);
    }
  }
  void _decrementCounterAutoclicker() async {
    if (_nbrVieRestant > 0) {
      setState(() {
        _nbrVieRestant-=GameView.nbrDegatsAutoClicker;
        if (_nbrVieRestant <0){
          _nbrVieRestant = 0;
        }
        _currentLife = _nbrVieRestant / _totalLife;
      });

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      await userViewModel.updateUserTotalExperience(
          widget.userId, GameView.totalExperience + 1);

      if (_nbrVieRestant <= 0) {
        _levelUp();
      }

      _controller.forward(from: 0.9);
    }
  }

  void _levelUp() async {
    setState(() {
      GameView.totalExperience += (GameView.gainExp * _user.id_ennemy).round(); // Ajoute de l'expérience en montant de niveau
      if (_user.id_ennemy%4==0){
        GameView.gainExp = ((GameView.gainExp + _user.id_ennemy )*2.7).round();
      }
      if (_user.nbr_mort_dern_ennemi >= 10 || _user.id_ennemy%5==0) {
        _user = UserModel(
          id: _user.id,
          pseudo: _user.pseudo,
          total_experience: _user.total_experience,
          id_ennemy: _user.id_ennemy + 1, // Mise à jour du niveau de l'ennemi
          nbr_mort_dern_ennemi: 0, // Réinitialisation du nombre de morts
        );

        // Mise à jour du niveau de l'ennemi via le UserViewModel
        final userViewModel =
            Provider.of<UserViewModel>(context, listen: false);
        userViewModel.updateIdEnnemi(
            _user.id, _user.id_ennemy); // Mise à jour de l'id_ennemy
        userViewModel.updateNbrMortDernEnnemi(
            _user.id, _user.nbr_mort_dern_ennemi);
      } else {
        _user = UserModel(
          id: _user.id,
          pseudo: _user.pseudo,
          total_experience: _user.total_experience,
          id_ennemy: _user.id_ennemy, // Reste le même
          nbr_mort_dern_ennemi:
              _user.nbr_mort_dern_ennemi + 1, // Incrémentation des morts
        );

        // Mise à jour du nombre de morts du dernier ennemi via le UserViewModel
        final userViewModel =
            Provider.of<UserViewModel>(context, listen: false);
        userViewModel.updateNbrMortDernEnnemi(
            _user.id, _user.nbr_mort_dern_ennemi);
      }
    });

    await _loadEnemyData();
  }

  Future<String> getEnemyImagePath(int enemyId) async {
    List<String> extensions = ['webp', 'png', 'gif'];

    for (String ext in extensions) {
      String path = 'assets/enemies/$enemyId.$ext';
      try {
        await rootBundle.load(path); // Essaie de charger l'image
        return path; // Si ça marche, on retourne ce chemin
      } catch (e) {
        // L'image avec cette extension n'existe pas, on essaie la suivante
      }
    }

    return 'assets/enemies/1.webp'; // Image par défaut si aucune n'existe
  }

  Widget _buildUpgradePanel() {
    return ameliorations.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : Expanded(
        child: ListView.builder(
          itemCount: ameliorations.length,
          itemBuilder: (context, index) {
            final amelioration = ameliorations[index];
            return Container(
              color: Colors.white, // Fond blanc
              margin: const EdgeInsets.symmetric(
                  vertical: 4.0), // Un peu d'espace entre les éléments
              child: ListTile(
                title: Text(amelioration.name +
                    " (niveau : ${amelioration.level})"),
                subtitle: Text(amelioration.description),
                trailing: ElevatedButton(
                  onPressed: () {
                    // Passe l'ID de l'élément à la méthode d'upgrade
                    _applyUpgrade(amelioration.id);
                  },
                  child: Text('${amelioration.costActual} XP'),
                ),
              ),
            );
          },
        ),
      );
  }

  Widget _buildShopPanel() {
    return shopItems.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Expanded(
      child: ListView.builder(
        itemCount: shopItems.length,
        itemBuilder: (context, index) {
          final item = shopItems[index];
          return Container(
            color: Colors.white,  // Fond blanc
            margin: const EdgeInsets.symmetric(vertical: 4.0),  // Un peu d'espace entre les éléments
            child: ListTile(
              title: Text(item.name),

              subtitle: Text(item.description),
              trailing: ElevatedButton(
                onPressed: () {
                  // Passe l'ID de l'élément à la méthode de purchase
                  _purchaseItem(item);
                },
                child: Text('${item.price} XP'),
              ),
            ),
          );
        },
      ),
    );
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
          onPressed: () {
            _stopAutoClicker(); // 🔥 Arrête l'auto-clicker avant de quitter
            Navigator.pop(context);
          },
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Pseudo : ${_user.pseudo}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2), // Décalage du shadow
                                    blurRadius: 3, // Flou pour adoucir le contour
                                    color: Colors.black, // Couleur du contour
                                  ),
                                ],),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            Text(
                              'Expérience : ${GameView.totalExperience}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2), // Décalage du shadow
                                    blurRadius: 3, // Flou pour adoucir le contour
                                    color: Colors.black, // Couleur du contour
                                  ),
                                ],),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isShowUpgradePanel =
                                  !_isShowUpgradePanel; // Active/désactive l'affichage
                              _isShowShopPanel = false; // Ferme Shop si ouvert
                            });
                            if (_isShowUpgradePanel) {
                              _showUpgradePanel(); // Appel de la fonction pour afficher le panneau du shop
                            }
                          },
                          icon: const Icon(Icons.upgrade, color: Colors.white),
                          label: const Text("Amélioration",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0)),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isShowShopPanel = !_isShowShopPanel;
                              _isShowUpgradePanel =
                                  false; // Ferme Amélioration si ouvert
                            });
                            if (_isShowShopPanel) {
                              _showShopPanel(); // Appel de la fonction pour afficher le panneau du shop
                            }
                          },
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.white),
                          label: const Text("Shop",
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0)),
                    if (_isShowUpgradePanel) _buildUpgradePanel(),
                    if (_isShowShopPanel) _buildShopPanel(),
                  ],
                )),
          ),
          Expanded(
            flex: 1,
            child: Container(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.84,
                      child: Image.asset(
                        'assets/images/background.webp',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Niveau ${_user.id_ennemy} : ${_enemy?.name}',
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold , color: Colors.white ,shadows: [
                            Shadow(
                              offset: Offset(2, 2), // Décalage du shadow
                              blurRadius: 3, // Flou pour adoucir le contour
                              color: Colors.black, // Couleur du contour

                            ),
                          ],),
                        ),
                        Text(
                          'Nombre de mort avant prochain niveau : ${_user.nbr_mort_dern_ennemi}/${_user.id_ennemy % 5 == 0 ? 1 : 10}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2), // Décalage du shadow
                                blurRadius: 3, // Flou pour adoucir le contour
                                color: Colors.black, // Couleur du contour
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Stack(
                            alignment: Alignment
                                .center,
                            // Centre le texte sur la barre
                            children: [
                              SizedBox(
                                height:
                                    20, // Augmente la hauteur pour une meilleure visibilité
                                child: LinearProgressIndicator(
                                  value:
                                      _currentLife, // Valeur dynamique entre 0.0 et 1.0
                                  backgroundColor:
                                      Colors.red[200], // Couleur de fond
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors
                                          .green), // Couleur de la vie restante
                                  minHeight: 20, // Ajuste la hauteur
                                ),
                              ),
                              Text(
                                '$_nbrVieRestant / $_totalLife', // Affichage des PV restants
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2), // Décalage du shadow
                                      blurRadius: 3, // Flou pour adoucir le contour
                                      color: Colors.black, // Couleur du contour
                                    ),
                                  ],
                                  // Assure une bonne visibilité
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
                            child: FutureBuilder<String>(
                              future: getEnemyImagePath(_user.id_ennemy),
                              builder: (context, snapshot) {
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return Image.asset('assets/enemies/1.webp',
                                      width: 150,
                                      height: 150); // Image par défaut
                                } else {
                                  return Image.asset(snapshot.data!,
                                      width: 150, height: 150);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
