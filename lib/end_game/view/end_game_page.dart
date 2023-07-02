import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/title/view/title_page.dart';
import 'package:lightrunners/ui/ui.dart';
import 'package:lightrunners/utils/gamepad_navigator.dart';
import 'package:lightrunners/widgets/widgets.dart';

class EndGamePage extends StatefulWidget {
  const EndGamePage({
    required this.scores,
    super.key,
  });

  final Map<Color, int> scores;

  static Route<void> route(Map<Color, int> scores) {
    return MaterialPageRoute<void>(
      maintainState: false,
      builder: (_) => EndGamePage(scores: scores),
    );
  }

  @override
  State<EndGamePage> createState() => _EndGamePageState();
}

class _EndGamePageState extends State<EndGamePage> {
  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late GamepadNavigator _gamepadNavigator;

  @override
  void initState() {
    super.initState();
    _gamepadNavigator = GamepadNavigator(
      onAny: () => Navigator.of(context).pushReplacement(TitlePage.route()),
    );
    _gamepadSubscription = Gamepads.events.listen(_gamepadNavigator.handle);
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontFamily = GoogleFonts.bungee().fontFamily;

    final scores = widget.scores.entries.toList()
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
              for (var i in [1, 0, 2])
                if (i < scores.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/ships/${shipSprites[GamePalette.shipValues.indexOf(scores[i].key)]}',
                            width: baseSize.toDouble(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${scores[i].value}',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontSize: 32,
                              color: scores[i].key,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: 180,
                            decoration: BoxDecoration(
                              color: scores[i].key,
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
