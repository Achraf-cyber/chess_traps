import 'package:flutter/material.dart';
import 'package:chess_traps/utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(context.phrase.home)));
  }
}
