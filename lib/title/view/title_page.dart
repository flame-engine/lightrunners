import 'package:flutter/material.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/title/title.dart';
import 'package:lightrunners/widgets/controller_menu.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

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
                      Navigator.of(context).push(GamePage.route());
                    },
                  ),
                  (
                    name: 'LeaderBoard',
                    onPressed: () {},
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
