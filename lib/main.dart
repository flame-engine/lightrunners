import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:flutter_con_game/components/ship.dart';
import 'package:flutter_con_game/title/title.dart';
import 'package:gamepads/gamepads.dart';

void main() {
  runApp(
    const MaterialApp(
      home: TitlePage(),
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
