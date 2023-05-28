import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:flutter_con_game/main.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GamePage(),
    );
  }

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final MyGame _game;

  @override
    void initState() {
      super.initState();
      _game = MyGame();
    }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
