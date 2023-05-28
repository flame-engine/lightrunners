import 'package:flutter/material.dart';
import 'package:lightrunners/title/title.dart';
import 'package:lightrunners/widgets/screen_scaffold.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      child: Center(
        child: TitleLogo(state: LogoController()),
      ),
    );
  }
}
