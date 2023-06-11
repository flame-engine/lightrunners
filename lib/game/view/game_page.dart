import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:lightrunners/end_game/end_game.dart';
import 'package:lightrunners/game/game.dart';

class GamePage extends StatefulWidget {
  const GamePage({required this.players, super.key});

  final List<String> players;

  static Route<void> route({required List<String> players}) {
    return MaterialPageRoute<void>(
      builder: (_) => GamePage(players: players),
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
      players: widget.players,
      onEndGame: (scores) {
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
