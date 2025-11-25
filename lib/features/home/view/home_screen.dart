import 'package:chess_traps/features/home/view/favorite_subscreen.dart';
import 'package:chess_traps/features/home/view/traps_subscreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ionicons/ionicons.dart';

import '../../../utils.dart';
import 'main_subscreen.dart';
import 'training_subscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.phrase.chessTraps)),
      body: [
        MainSubscreen(),
        TrapsSubscreen(),
        FavoriteSubscreen(),
        TrainingSubscreen(),
      ][navIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: context.phrase.home,
            activeIcon: Icon(Icons.home_filled),
            tooltip: context.phrase.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chess),
            label: context.phrase.traps,
            activeIcon: Icon(FontAwesomeIcons.chess),
            tooltip: context.phrase.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: context.phrase.favorite,
            activeIcon: Icon(Icons.home_filled),
            tooltip: context.phrase.favorite,
          ),
          BottomNavigationBarItem(
            icon: Icon(Ionicons.train),
            label: context.phrase.training,
            activeIcon: Icon(Ionicons.train),
            tooltip: context.phrase.training,
          ),
        ],
        currentIndex: navIndex,
        onTap: (value) {
          setState(() {
            navIndex = value;
          });
        },
      ),
    );
  }
}
