import 'package:flutter/material.dart';
import 'package:lightrunners/title/title.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TitlePage(),
      themeMode: ThemeMode.dark,
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
