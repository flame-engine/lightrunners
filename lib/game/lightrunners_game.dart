import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/components/background.dart';
import 'package:lightrunners/game/components/game_border.dart';
import 'package:lightrunners/game/components/powerup.dart';
import 'package:lightrunners/game/components/score_panel.dart';
import 'package:lightrunners/game/components/spotlight.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/utils/constants.dart';
import 'package:lightrunners/utils/utils.dart';

class LightRunnersGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final List<String?> players;
  late final Rect playArea;
  late final CameraComponent cameraComponent;
  late final World world;
  late final Map<String, Ship> ships;

  StreamSubscription<GamepadEvent>? _subscription;
  final void Function(Map<Color, int>) onEndGame;

  LightRunnersGame({required this.players, required this.onEndGame});

  @override
  Future<void> onLoad() async {
    _createShips();
    world = World();

    cameraComponent = CameraComponent.withFixedResolution(
      world: world,
      width: fixedSize.x,
      height: fixedSize.y,
    );
    add(cameraComponent);

    playArea = Rect.fromLTWH(
      screenMargin - fixedSize.x / 2,
      screenMargin - fixedSize.y / 2,
      fixedSize.x - 2 * screenMargin - scoreBoxWidth - 2 * scoreBoxMargin,
      fixedSize.y - 2 * screenMargin,
    );
    cameraComponent.viewport.add(ScorePanel());
    world.addAll([Background(), GameBorder()]);
    world.addAll([Spotlight(), ...ships.values]);
    add(world);

    late final CountDown countDown;
    add(
      countDown = CountDown(
        onTimeUp: () {
          countDown.removeFromParent();
          onEndGame({
            for (final ship in ships.values) ship.paint.color: ship.score,
          });
        },
      ),
    );

    add(
      TimerComponent(
        period: 10,
        repeat: true,
        onTick: () {
          world.add(PowerUp());
        },
      ),
    );
  }

  void _createShips() {
    ships = {
      for (var i = 0; i < players.length; i++)
        players[i] ?? 'keyboard_$i': Ship(i, players[i]),
    };

    if (ships.isEmpty) {
      print('No controllers found, using keyboard only');
      ships[''] = Ship(0, null);
    }

    _subscription = Gamepads.events.listen((event) {
      ships[event.gamepadId]?.onGamepadEvent(event);
    });
  }

  @override
  void onRemove() {
    _subscription?.cancel();
  }
}
