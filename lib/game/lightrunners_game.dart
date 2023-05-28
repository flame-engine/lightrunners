import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/components/game_border.dart';
import 'package:lightrunners/game/components/score_panel.dart';
import 'package:lightrunners/game/components/spotlight.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/utils/constants.dart';

class LightRunnersGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  late final Rect playArea;
  late final CameraComponent cameraComponent;
  late final World world;
  late final Map<String, Ship> ships;

  StreamSubscription<GamepadEvent>? _subscription;

  @override
  Future<void> onLoad() async {
    playArea = Rect.fromLTWH(
      screenMargin,
      screenMargin,
      size.x - 2 * screenMargin - scoreBoxWidth - 2 * scoreBoxMargin,
      size.y - 2 * screenMargin,
    );
    await add(GameBorder());

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
    await add(ScorePanel());

    world = World(
      children: [Spotlight(), ...ships.values],
    );
    cameraComponent = CameraComponent(world: world);
    await addAll([world, cameraComponent]);
  }

  @override
  void onRemove() {
    _subscription?.cancel();
  }
}
