import 'dart:async';
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/components/background.dart';
import 'package:lightrunners/game/components/game_border.dart';
import 'package:lightrunners/game/components/score_panel.dart';
import 'package:lightrunners/game/components/spotlight.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/utils/constants.dart';
import 'package:lightrunners/utils/utils.dart';

class LightRunnersGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final List<String> players;
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
    await add(cameraComponent);

    playArea = Rect.fromLTWH(
      screenMargin - fixedSize.x / 2,
      screenMargin - fixedSize.y / 2,
      fixedSize.x - 2 * screenMargin - scoreBoxWidth - 2 * scoreBoxMargin,
      fixedSize.y - 2 * screenMargin,
    );
    await world.addAll([Background(), GameBorder(), ScorePanel()]);
    await world.addAll([Spotlight(), ...ships.values]);
    await add(world);

    late CountDown countDown;
    await add(
      countDown = CountDown(
        onTimeUp: () {
          countDown.removeFromParent();
          onEndGame({
            for (final ship in ships.values) ship.paint.color: ship.score,
          });
        },
      ),
    );
  }

  void _createShips() {
    ships = {
      for (final player in players)
        player: Ship(players.indexOf(player), player),
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
