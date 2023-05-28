import 'package:flutter/material.dart';

import 'package:flutter_con_game/title/title.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      home: TitlePage(),
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
