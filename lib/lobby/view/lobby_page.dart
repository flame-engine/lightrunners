import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/game/view/game_page.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const LobbyPage(),
    );
  }

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final List<String?> _players = [];

  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode()..requestFocus();

    _gamepadSubscription = Gamepads.events.listen((GamepadEvent event) {
      setState(() {
        if (event.key == '7' || event.key == 'line.horizontal.3.circle') {
          // The start key was pressed
          Navigator.of(context).push(GamePage.route(players: _players));
        } else if (!_players.contains(event.gamepadId)) {
          _players.add(event.gamepadId);
        }
      });
    });
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const centerTextStyle = TextStyle(
      color: GamePalette.lightBlue,
      fontSize: 48.0,
      fontWeight: FontWeight.bold,
    );

    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: (RawKeyEvent event) {
        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          setState(() {
            _players.add(null);
          });
        } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          // The start key was pressed
          Navigator.of(context).push(GamePage.route(players: _players));
        }
      },
      child: ScreenScaffold(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerRectangle(id: 0, players: _players),
                PlayerRectangle(id: 1, players: _players),
                PlayerRectangle(id: 2, players: _players),
                PlayerRectangle(id: 3, players: _players),
              ],
            ),
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Waiting for',
                    style: centerTextStyle,
                  ),
                  Text(
                    'players...',
                    style: centerTextStyle,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerRectangle(id: 4, players: _players),
                PlayerRectangle(id: 5, players: _players),
                PlayerRectangle(id: 6, players: _players),
                PlayerRectangle(id: 7, players: _players),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerRectangle extends StatelessWidget {
  final int id;
  final List<String?> players;

  const PlayerRectangle({
    required this.id,
    required this.players,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = GamePalette.shipValues[id];
    final hasJoined = id < players.length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 100,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: color,
            width: 6.0,
          ),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.6), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            hasJoined ? 'Joined' : 'Waiting...',
            style: TextStyle(
              fontFamily: GoogleFonts.bungee().fontFamily,
              color: color,
              fontSize: 24.0,
            ),
          ),
        ),
      ),
    );
  }
}
