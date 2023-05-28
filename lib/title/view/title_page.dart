import 'package:flutter/material.dart';
import 'package:flutter_con_game/game/game.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text('Title Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(GamePage.route());
              },
              child: const Text('Go to Game Page'),
            ),
          ],
        ),
      ),
    );
  }
}
