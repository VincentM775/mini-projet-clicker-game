// import '../models/case_model.dart';
// import '../models/map_model.dart';
// import 'package:flutter/material.dart';
//
// class GameViewModel extends ChangeNotifier {
//   final MapModel _mapModel;
//
//   GameViewModel(this._mapModel);
//
//   MapModel get map => _mapModel;
//   List<List<CaseModel>> get cases => map.cases;
//
//   int get lines => _mapModel.nbLine;
//   int get cols => _mapModel.nbCol;
//   int get bombs => _mapModel.nbBomb;
//   int get remainingFlags => _mapModel.remainingFlags;
//
//   void setGame(int nbLine, int nbCol, int nbBomb) {
//     map.nbLine = nbLine;
//     map.nbCol = nbCol;
//     map.nbBomb = nbBomb;
//     generateMap();
//   }
//
//   void generateMap() {
//     _mapModel.generateMap();
//     notifyListeners();
//   }
//
//   void click(int x, int y) {
//     CaseModel caseMod = _mapModel.caseModel(x, y);
//     if (!caseMod.hidden) return;
//
//     if (caseMod.hasBomb) {
//       _mapModel.explode(x, y);
//       _mapModel.revealAll();
//     } else {
//       _mapModel.reveal(x, y);
//     }
//     notifyListeners();
//   }
//
//   void onLongPress(int x, int y) {
//     CaseModel caseMod = _mapModel.caseModel(x, y);
//     if (caseMod.hidden) {
//       _mapModel.toggleFlag(x, y);
//       notifyListeners();
//     }
//   }
//
//   Image getIcon(int x, int y) {
//     CaseModel caseMod = _mapModel.caseModel(x, y);
//
//     if (caseMod.hasFlag) {
//       return Image.asset('assets/images/drapeau.png');
//     }
//     if (caseMod.hidden) {
//       return Image.asset('assets/images/case.png');
//     }
//     if (caseMod.hasExploded) {
//       return Image.asset('assets/images/bombe-explose.png');
//     }
//     if (!caseMod.hidden && caseMod.hasBomb && caseMod.hasExploded==false) {
//       return Image.asset('assets/images/bombe.png');
//     }
//
//     const Map<int, String> numberIcons = {
//       1: 'assets/num/1.png',
//       2: 'assets/num/2.png',
//       3: 'assets/num/3.png',
//       4: 'assets/num/4.png',
//       5: 'assets/num/5.png',
//       6: 'assets/num/6.png',
//       7: 'assets/num/7.png',
//       8: 'assets/num/8.png',
//     };
//
//     String imagePath = numberIcons[caseMod.number] ?? 'assets/images/vide.png';
//     return Image.asset(imagePath);
//   }
// }