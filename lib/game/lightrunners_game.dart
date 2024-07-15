import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/components/background.dart';
import 'package:lightrunners/game/components/game_border.dart';
import 'package:lightrunners/game/components/powerup.dart';
import 'package:lightrunners/game/components/score_panel.dart';
import 'package:lightrunners/game/components/spotlight.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/game/player.dart';
import 'package:lightrunners/utils/constants.dart';
import 'package:lightrunners/utils/utils.dart';

class LightRunnersGame extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  final List<Player> players;
  late final Rect playArea;
  late final Map<String, Ship> ships;

  StreamSubscription<GamepadEvent>? _subscription;
  final void Function(Map<Player, int>) onEndGame;

  LightRunnersGame({
    required this.players,
    required this.onEndGame,
  }) : super(
          camera: CameraComponent.withFixedResolution(
            world: World(),
            width: fixedSize.x,
            height: fixedSize.y,
          ),
        );

  @override
  Future<void> onLoad() async {
    _createShips();

    playArea = Rect.fromLTWH(
      screenMargin - fixedSize.x / 2,
      screenMargin - fixedSize.y / 2,
      fixedSize.x - 2 * screenMargin - scoreBoxWidth - 2 * scoreBoxMargin,
      fixedSize.y - 2 * screenMargin,
    );

    world.addAll([
      Background(),
      GameBorder(),
      Spotlight(),
      ...ships.values,
      ScorePanel(),
    ]);

    late final CountDown countDown;
    add(
      countDown = CountDown(
        onTimeUp: () {
          countDown.removeFromParent();
          onEndGame({
            for (final ship in ships.values) ship.player: ship.score,
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
        players[i].gamepadId ?? 'keyboard_$i': Ship(players[i]),
    };

    _subscription = Gamepads.events.listen((event) {
      ships[event.gamepadId]?.onGamepadEvent(event);
    });
  }

  @override
  void onRemove() {
    _subscription?.cancel();
  }
}
