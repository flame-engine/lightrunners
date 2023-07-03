import 'package:flutter/material.dart';
import 'package:lightrunners/audio/audio.dart';
import 'package:lightrunners/leaderboard/view/view.dart';
import 'package:lightrunners/lobby/view/lobby_page.dart';
import 'package:lightrunners/title/title.dart';
import 'package:lightrunners/widgets/controller_menu.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class TitlePage extends StatefulWidget {
  static Route<void> route() {
    return MaterialPageRoute<void>(
      maintainState: false,
      builder: (_) => const TitlePage(),
    );
  }

  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  @override
  void initState() {
    super.initState();

    final audioManager = AudioManager();

    audioManager.stopBgm();

    audioManager.introSfx();

    Future.delayed(const Duration(milliseconds: 1500), audioManager.playTitle);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: TitleLogo(state: LogoController()),
          ),
          Flexible(
            child: Center(
              child: ControllerMenu(
                options: [
                  (
                    name: 'Start',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(LobbyPage.route());
                    },
                  ),
                  (
                    name: 'LeaderBoard',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        LeaderboardPage.route(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
