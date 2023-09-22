import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/firebase/score.dart';
import 'package:lightrunners/firebase/score_calculator.dart';
import 'package:lightrunners/firebase/scores.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/game/player.dart';
import 'package:lightrunners/title/view/title_page.dart';
import 'package:lightrunners/ui/ui.dart';
import 'package:lightrunners/utils/gamepad_navigator.dart';
import 'package:lightrunners/widgets/widgets.dart';

class EndGamePage extends StatefulWidget {
  const EndGamePage({
    required this.points,
    super.key,
  });

  final Map<Player, int> points;

  static Route<void> route(Map<Player, int> points) {
    return MaterialPageRoute<void>(
      maintainState: false,
      builder: (_) => EndGamePage(points: points),
    );
  }

  @override
  State<EndGamePage> createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late GamepadNavigator _gamepadNavigator;

  bool isScavengerHunt = true;
  bool updatingFirebase = true;
  bool receivedTopPlayers = false;
  bool minDurationElapsed = false;
  Iterable<Score> topPlayers = [];

  bool get canMoveOn =>
      !updatingFirebase && minDurationElapsed && receivedTopPlayers;

  @override
  void initState() {
    super.initState();
    _updateFirebase().whenComplete(_fetchTopPlayers);
    _gamepadNavigator = GamepadNavigator(
      onAny: () {
        if (canMoveOn) {
          Navigator.of(context).pushReplacement(TitlePage.route());
        }
      },
    );
    _gamepadSubscription = Gamepads.events.listen(_gamepadNavigator.handle);
    Future.delayed(const Duration(seconds: 10), () {
      setState(() => minDurationElapsed = true);
    });
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();

    super.dispose();
  }

  Future<void> _updateFirebase() async {
    final scores = ScoreCalculator.computeScores(widget.points);
    final futures = scores.entries
        .where((entry) => entry.key.playerId != null)
        .map((entry) {
      return Scores.updateScore(
        playerId: entry.key.playerId!,
        score: entry.value,
      );
    });
    await Future.wait(futures);
    setState(() => updatingFirebase = false);
  }

  Future<void> _fetchTopPlayers() async {
    final topPlayers = await Scores.fetchTopPlayers(
      playerIds: widget.points.keys.map((p) => p.playerId).whereType<int>(),
    );
    setState(() {
      this.topPlayers = topPlayers;
      receivedTopPlayers = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.bungee().fontFamily;

    final scores = widget.points.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const baseSize = 64;
    const badges = [
      'gold.png',
      'silver.png',
      'bronze.png',
    ];

    return ScreenScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: 16),
          Text(
            'Game Result',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 72,
              color: GamePalette.white,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final i in [1, 0, 2])
                if (i < scores.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/ships/${shipSprites[GamePalette.shipValues.indexOf(scores[i].key.color)]}',
                            width: baseSize.toDouble(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${scores[i].value}',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 32,
                              color: scores[i].key.color,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: 180,
                            decoration: BoxDecoration(
                              color: scores[i].key.color,
                              backgroundBlendMode: BlendMode.colorBurn,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.8),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            height: (scores.length - i) /
                                scores.length *
                                baseSize *
                                4,
                            child: Image.asset(
                              'assets/images/${badges[i]}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
          if (isScavengerHunt && topPlayers.isNotEmpty) ...[
            Text(
              'Congratulations, the following players have received\n'
              'an achievement and can scan the QR code with the F3 app!',
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 32,
                color: GamePalette.yellow,
              ),
            ),
            Text(
              topPlayers.map((p) => p.username).join(' | '),
              style: TextStyle(
                fontFamily: fontFamily,
                fontSize: 32,
                color: GamePalette.lightBlue,
              ),
            ),
            Align(
              child: Image.asset(
                'assets/images/qr-top.png',
                width: 600,
                height: 600,
                fit: BoxFit.cover,
              ),
            ),
          ],
          OpacityBlinker(
            child: TextButton(
              onPressed: () =>
                  Navigator.of(context).pushReplacement(TitlePage.route()),
              child: Text(
                'Press any button to continue',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 32,
                  color: GamePalette.silver,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
