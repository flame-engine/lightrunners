import 'package:flutter/material.dart';
import 'package:flutter_con_game/widgets/screen_scaffold.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScreenScaffold(
      child: Center(
        child: Text('Title Page'),
      ),
    );
  }
}
