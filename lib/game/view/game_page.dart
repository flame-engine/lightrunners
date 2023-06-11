import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:lightrunners/end_game/end_game.dart';
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
    _game = LightRunnersGame(
      (scores) {
        Navigator.of(context).push(
          EndGamePage.route(scores),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
