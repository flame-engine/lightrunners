import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_con_game/components/ship.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: MyGame.new));
}

class MyGame extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cameraComponent;
  late final World world;

  @override
  Future<void> onLoad() async {
    world = World(children: [Ship()]);
    cameraComponent = CameraComponent(world: world);
    await addAll([world, cameraComponent]);
  }
}
