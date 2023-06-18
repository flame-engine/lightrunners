import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/ui/ui.dart';
import 'package:lightrunners/utils/gamepad_map.dart';
import 'package:lightrunners/utils/input_handler_utils.dart';

class _KeyboardControls {
  const _KeyboardControls({
    required this.up,
    required this.left,
    required this.down,
    required this.right,
    required this.shoot,
  });

  final LogicalKeyboardKey up;
  final LogicalKeyboardKey left;
  final LogicalKeyboardKey down;
  final LogicalKeyboardKey right;
  final LogicalKeyboardKey shoot;
}

const playerKeyboardControlsMapping = [
  _KeyboardControls(
    up: LogicalKeyboardKey.keyW,
    left: LogicalKeyboardKey.keyA,
    down: LogicalKeyboardKey.keyS,
    right: LogicalKeyboardKey.keyD,
    shoot: LogicalKeyboardKey.keyR,
  ),
  _KeyboardControls(
    up: LogicalKeyboardKey.arrowUp,
    left: LogicalKeyboardKey.arrowLeft,
    down: LogicalKeyboardKey.arrowDown,
    right: LogicalKeyboardKey.arrowRight,
    shoot: LogicalKeyboardKey.keyM,
  ),
];

final _shipColors =
    GamePalette.shipValues.map((color) => Paint()..color = color).toList();

final shipSprites = [
  'netunos_wrath.png',
  'andromedas_revenge.png',
  'purple_haze.png',
  'silver_bullet.png',
  'crimson_fury.png',
  'star_chaser.png',
  'photon_raider.png',
  'dagger_of_venus.png',
];

GamepadJoystick? _makeJoystick(
  String? gamepadId,
  GamepadKey xAxisKey,
  GamepadKey yAxisKey,
) {
  if (gamepadId == null) {
    return null;
  }
  return GamepadJoystick(
    gamepadId: gamepadId,
    xAxisKey: xAxisKey,
    yAxisKey: yAxisKey,
  );
}

class Ship extends SpriteComponent
    with
        KeyboardHandler,
        HasGameReference<LightRunnersGame>,
        CollisionCallbacks {
  static const _engine = 125.0;
  static const _drag = 5.0;
  static const _bulletSpeed = 300.0;

  Ship(this.playerNumber, this.gamepadId)
      : moveJoystick = _makeJoystick(
          gamepadId,
          const GamepadLeftXAxis(),
          const GamepadLeftYAxis(),
        ),
        super(
          size: Vector2(40, 80),
          anchor: Anchor.center,
        ) {
    paint = _shipColors[playerNumber];
    spritePath = shipSprites[playerNumber];
  }

  final int playerNumber;
  final String? gamepadId; // null means keyboard
  int score = 0;
  late final String spritePath;

  final Vector2 velocity = Vector2.zero();
  final Vector2 drag = Vector2.zero();
  final Vector2 engine = Vector2.zero();
  final Vector2 acceleration = Vector2.zero();

  final GamepadJoystick? moveJoystick;
  final Vector2 move = Vector2.zero();

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('ships/$spritePath');
    debugMode = true;
    add(RectangleHitbox());
  }

  void fire() {
    final bulletVector = Vector2(
      math.sin(angle),
      math.cos(angle) * -1,
    )..normalized();

    game.world.add(
      Bullet(
        ownerPlayerNumber: playerNumber,
        position: position + (move..scaled(size.length2)),
        velocity: bulletVector * _bulletSpeed,
      ),
    );
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final keyboardControl = playerKeyboardControlsMapping[playerNumber];

    if (event.isKeyPressed(keyboardControl.shoot)) {
      fire();
      return false;
    }

    return readArrowLikeKeysIntoVector2(
      event,
      keysPressed,
      move,
      up: keyboardControl.up,
      left: keyboardControl.left,
      down: keyboardControl.down,
      right: keyboardControl.right,
    );
  }

  void onGamepadEvent(GamepadEvent event) {
    _handleGamepadAxisInput(moveJoystick, event, move);
    _handleGamedpadShootEvent(event);
  }

  void _handleGamedpadShootEvent(GamepadEvent event) {
    // TODO(all): Implement this, I don't have a gamepad to test with.
  }

  void _handleGamepadAxisInput(
    GamepadJoystick? joystick,
    GamepadEvent event,
    Vector2 target,
  ) {
    if (joystick == null) {
      return;
    }
    joystick.consume(event);
    target.x = joystick.state.x;
    target.y = joystick.state.y;
  }

  // These are used to avoid creating new Vector2 objects in the update-loop.
  final _velocityTmp = Vector2.zero();
  final _accelerationTmp = Vector2.zero();

  @override
  void update(double dt) {
    // TODO(any): Restrict movement to only allow ship to be within screen.

    final dt2 = dt * dt;

    engine
      ..setFrom(move)
      ..scale(_engine);
    drag
      ..setFrom(velocity)
      ..scaleTo(_drag)
      ..scale(-1);
    acceleration
      ..setFrom(engine)
      ..add(drag);

    _accelerationTmp
      ..setFrom(acceleration)
      ..scale(dt);
    velocity.add(_accelerationTmp);

    _velocityTmp
      ..setFrom(velocity)
      ..scale(dt);
    _accelerationTmp
      ..setFrom(acceleration)
      ..scale(dt2 / 2);
    position
      ..add(_velocityTmp)
      ..add(_accelerationTmp);

    if (!engine.isZero()) {
      angle = -engine.angleToSigned(Vector2(0, -1));
    }

    if (position.x + size.x < game.playArea.left) {
      position.x = game.playArea.right;
    }

    if (position.x > game.playArea.right) {
      position.x = game.playArea.left - size.x;
    }

    if (position.y + size.y < game.playArea.top) {
      position.y = game.playArea.bottom;
    }

    if (position.y > game.playArea.bottom) {
      position.y = game.playArea.top - size.y;
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      if (other.ownerPlayerNumber == playerNumber) {
        return;
      }
      // TODO(any): Affect velocity by getting shot
      other.removeFromParent();
    } else if (other is Ship) {
      // TODO(any): Don't let ships overlap
    }
  }
}
