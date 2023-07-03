import 'package:flame/game.dart' hide Route;
import 'package:flutter/material.dart';
import 'package:lightrunners/audio/audio.dart';
import 'package:lightrunners/end_game/end_game.dart';
import 'package:lightrunners/game/game.dart';

class GamePage extends StatefulWidget {
  const GamePage({required this.players, super.key});

  final List<(String?, String?)> players;

  static Route<void> route({required List<(String?, String?)> players}) {
    return MaterialPageRoute<void>(
      maintainState: false,
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

    AudioManager().playGame();

    _game = LightRunnersGame(
      players: widget.players,
      onEndGame: (scores) {
        Navigator.of(context).pushReplacement(
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
