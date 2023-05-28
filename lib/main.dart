import 'package:flutter/material.dart';

import 'package:flutter_con_game/title/title.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      home: const TitlePage(),
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE0D932),
          secondary: Color(0xFFE032CF),
        ),
        textTheme: GoogleFonts.bungeeShadeTextTheme(),
      ),
    ),
  );
}
