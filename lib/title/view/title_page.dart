import 'package:flutter/material.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/title/title.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Column(
        children: [
          TitleLogo(state: LogoController()),
          ElevatedButton(
            child: const Text('Go to Game Page'),
            onPressed: () {
              Navigator.of(context).push(GamePage.route());
            },
          ),
        ],
      ),
    );
  }
}
