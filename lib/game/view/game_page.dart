import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:lightrunners/game/game.dart';

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
  late final LightRunnersGame _game;

  @override
  void initState() {
    super.initState();
    _game = LightRunnersGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
