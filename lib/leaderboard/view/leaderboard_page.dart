import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/firebase/score.dart';
import 'package:lightrunners/firebase/scores.dart';
import 'package:lightrunners/title/title.dart';
import 'package:lightrunners/utils/gamepad_navigator.dart';
import 'package:lightrunners/widgets/widgets.dart';

const _maxScoreDigits = 3;
const _maxCharactersScoreBoard = 26;
const _lightrunnersInfoBlob =
    '''Light Runners was made with 💙 by Blue Fire and Invertase for Fluttercon 2023
''';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({
    super.key,
  });

  static Route<void> route() {
    return MaterialPageRoute<void>(
      maintainState: false,
      builder: (_) => const LeaderboardPage(),
    );
  }

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late GamepadNavigator _gamepadNavigator;

  bool loading = true;
  List<Score> scores = [];

  @override
  void initState() {
    super.initState();
    _gamepadNavigator = GamepadNavigator(
      onAny: () => Navigator.of(context).pushReplacement(TitlePage.route()),
    );
    _gamepadSubscription = Gamepads.events.listen(_gamepadNavigator.handle);
    _updateScores();
  }

  Future<void> _updateScores() async {
    final scores = await Scores.topScores();
    setState(() {
      loading = false;
      this.scores = scores;
    });
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bungee = GoogleFonts.bungee().fontFamily;
    final major = GoogleFonts.majorMonoDisplay().fontFamily;

    return ScreenScaffold(
      child: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: TitleLogo(state: LogoController())),
                  Text(
                    _lightrunnersInfoBlob,
                    style: TextStyle(
                      fontFamily: bungee,
                      fontSize: 48,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(64.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const CircularProgressIndicator()
                  else
                    for (final score in scores)
                      Text(
                        _toScoreboardLine(score),
                        style: TextStyle(
                          fontFamily: major,
                          fontWeight: FontWeight.bold,
                          fontSize: 38,
                          color: Colors.white,
                        ),
                      )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toScoreboardLine(Score record) {
    final name = record.email.substring(
      0,
      min(record.email.length, _maxCharactersScoreBoard - _maxScoreDigits - 1),
    );
    final maxScore = pow(10, _maxScoreDigits) - 1;
    final score = record.score
        .clamp(0, maxScore)
        .toString()
        .padLeft(_maxScoreDigits, '0');
    final dotDotDot =
        '.' * (_maxCharactersScoreBoard - name.length - score.length);

    return '$name$dotDotDot$score'.toLowerCase();
  }
}
