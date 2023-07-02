import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/shaders/shaders.dart';
import 'package:lightrunners/title/title.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(
    CRTShader(
      enabled: true,
      child: MaterialApp(
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
    ),
  );
}
