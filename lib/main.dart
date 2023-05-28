import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter_con_game/components/ship.dart';
import 'package:flutter_con_game/title/title.dart';
import 'package:gamepads/gamepads.dart';
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

class MyGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final CameraComponent cameraComponent;
  late final World world;
  late final Map<String, Ship> ships;

  StreamSubscription<GamepadEvent>? _subscription;

  @override
  Future<void> onLoad() async {
    final gamepads = await Gamepads.list();
    gamepads.forEach((g) => print(g.id));
    ships = {
      for (final gamepad in gamepads)
        gamepad.id: Ship(gamepads.indexOf(gamepad), gamepad.id),
    };
    if (ships.isEmpty) {
      print('No controllers found, using keyboard only');
      ships[''] = Ship(0, null);
    }
    _subscription = Gamepads.events.listen((event) {
      ships[event.gamepadId]?.onGamepadEvent(event);
    });

    world = World(children: ships.values);
    cameraComponent = CameraComponent(world: world);
    await addAll([world, cameraComponent]);
  }

  @override
  void onRemove() {
    _subscription?.cancel();
  }
}
