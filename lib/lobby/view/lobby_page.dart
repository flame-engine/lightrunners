import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/game/player.dart';
import 'package:lightrunners/game/view/game_page.dart';
import 'package:lightrunners/title/view/title_page.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/gamepad_map.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      maintainState: false,
      builder: (_) => const LobbyPage(),
    );
  }

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final List<Player> _players = [];

  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..requestFocus();

    _gamepadSubscription = Gamepads.events.listen((GamepadEvent event) {
      setState(() {
        if (startButton.matches(event) &&
            !_players.any((p) => p.username == null)) {
          Navigator.of(context)
              .pushReplacement(GamePage.route(players: _players));
        } else if (selectButton.matches(event)) {
          Navigator.of(context).pushReplacement(TitlePage.route());
        } else if (_players
                .where((player) => player.gamepadId == event.gamepadId)
                .isEmpty &&
            aButton.matches(event)) {
          _players.add(
            Player(slotNumber: _players.length, gamepadId: event.gamepadId),
          );
        }
      });
    });
  }

  void onPlayerIdentified(int id, String username) {
    setState(() {
      _players[id] = _players[id].copyWith(playerId: id, username: username);
    });
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
            _players.add(Player(slotNumber: _players.length));
          });
        } else if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          // The start key was pressed
          Navigator.of(context)
              .pushReplacement(GamePage.route(players: _players));
        }
      },
      child: ScreenScaffold(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlayerRectangle(
                  id: 0,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 1,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 2,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 3,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
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
                PlayerRectangle(
                  id: 4,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 5,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 6,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
                PlayerRectangle(
                  id: 7,
                  players: _players,
                  onPlayerIdentified: onPlayerIdentified,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();
    _focusNode.dispose();

    super.dispose();
  }
}

class PlayerRectangle extends StatelessWidget {
  final int id;
  final List<Player> players;
  final void Function(int, String) onPlayerIdentified;

  const PlayerRectangle({
    required this.id,
    required this.players,
    required this.onPlayerIdentified,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final color = GamePalette.shipValues[id];
    final hasJoined = id < players.length;
    final hasIdentified = hasJoined && players[id].username != null;

    final child = hasJoined && !hasIdentified
        ? PlayerIdentification(
            gamePadId: players[id].gamepadId!,
            onPlayerIdentified: (String playerId) {
              onPlayerIdentified(id, playerId);
            },
          )
        : Text(
            hasJoined ? 'Ready' : 'Waiting...',
            style: TextStyle(
              fontFamily: GoogleFonts.bungee().fontFamily,
              color: color,
              fontSize: 28.0,
            ),
          );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 200,
        width: 400,
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
        child: Center(child: child),
      ),
    );
  }
}

class PlayerIdentification extends StatefulWidget {
  final String gamePadId;

  const PlayerIdentification({
    required this.gamePadId,
    required this.onPlayerIdentified,
    super.key,
  });

  final void Function(String) onPlayerIdentified;

  @override
  State<PlayerIdentification> createState() => _PlayerIdentificationState();
}

class _PlayerIdentificationState extends State<PlayerIdentification> {
  var _selectedPlayerMode = false;
  var _playerId = '0000';
  var _cursor = 0;

  late StreamSubscription<GamepadEvent> _gamepadSubscription;

  @override
  void initState() {
    super.initState();

    _gamepadSubscription = Gamepads.events.listen((GamepadEvent event) {
      setState(() {
        if (event.gamepadId == widget.gamePadId) {
          if (_selectedPlayerMode == false) {
            if (aButton.matches(event)) {
              setState(() {
                _selectedPlayerMode = true;
              });
            } else if (bButton.matches(event)) {
              widget.onPlayerIdentified('guest');
            }
          } else {
            if (aButton.matches(event)) {
              // Increment current digit
              final digit =
                  int.parse(_playerId.substring(_cursor, _cursor + 1));
              final newDigit = (digit + 1) % 10;
              setState(() {
                _playerId = _playerId.replaceRange(
                  _cursor,
                  _cursor + 1,
                  '$newDigit',
                );
              });
            } else if (r1Bumper.matches(event) && event.value > 30000) {
              // Move the cursor to the next digit if R1 is fully pressed
              setState(() {
                _cursor = (_cursor + 1) % _playerId.characters.length;
              });
            } else if (startButton.matches(event)) {
              // Identify player
              widget.onPlayerIdentified(_playerId);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontFamily: GoogleFonts.bungee().fontFamily,
      color: Colors.white,
      fontSize: 28.0,
    );

    if (_selectedPlayerMode) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 14),
          Text(
            'Enter player id',
            style: textStyle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < _playerId.characters.length; i++)
                Expanded(
                  child: Text(
                    _playerId.substring(i, i + 1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: GoogleFonts.bungee().fontFamily,
                      color: Colors.white,
                      fontSize: 28.0,
                      decoration: _cursor == i
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '(A) to identify Player',
            style: textStyle,
          ),
          const SizedBox(height: 12),
          Text(
            '(B) to play as guest',
            style: textStyle,
          ),
        ],
      );
    }
  }
}
