import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/game/player.dart';
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

final shipSprites = [
  'netunos_wrath.png',
  'purple_haze.png',
  'silver_bullet.png',
  'crimson_fury.png',
  'star_chaser.png',
  'photon_raider.png',
  'dagger_of_venus.png',
  'andromedas_revenge.png',
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
  static final _random = Random();

  Ship(this.player) :
        moveJoystick = _makeJoystick(player.gamepadId, leftXAxis, leftYAxis),
        super(size: Vector2(40, 80), anchor: Anchor.center) {
    paint = Paint()..color = player.color;
    spritePath = shipSprites[player.slotNumber];
  }

  final Player player;
  int score = 0;
  late final String spritePath;

  double engineStrength = 125.0;
  double bulletSpeed = 400.0;
  double weightFactor = 1.0;
  double dragFactor = 5.0;

  final Vector2 velocity = Vector2.zero();
  final Vector2 drag = Vector2.zero();
  final Vector2 engine = Vector2.zero();
  final Vector2 acceleration = Vector2.zero();

  final GamepadJoystick? moveJoystick;
  final Vector2 move = Vector2.zero();
  late final double _halfDiagonal;

  @override
  Future<void> onLoad() async {
    _halfDiagonal = size.length / 2;
    sprite = await game.loadSprite('ships/$spritePath');
    position = Vector2.random(_random)
      ..multiply(game.playArea.toVector2() / 2)
      ..multiply(
        Vector2(_random.nextBool() ? 1 : -1, _random.nextBool() ? 1 : -1),
      );
    angle = _random.nextDouble() * tau;
    add(
      PolygonHitbox.relative(
        [
          Vector2(-1, 1),
          Vector2(1, 1),
          Vector2(0, -1),
        ],
        parentSize: size,
      ),
    );
  }

  void fire() {
    final bulletVector = Vector2(sin(angle), -cos(angle))..normalized();

    game.world.add(
      Bullet(
        ownerPlayerNumber: player.slotNumber,
        position: positionOfAnchor(Anchor.topCenter),
        velocity: bulletVector * bulletSpeed,
        color: paint.color,
      ),
    );
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final keyboardControl = playerKeyboardControlsMapping[player.slotNumber];

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
    if (aButton.matches(event) || r1Bumper.matches(event)) {
      fire();
    }
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
    final dt2 = dt * dt;

    engine
      ..setFrom(move)
      ..scale(engineStrength);
    drag
      ..setFrom(velocity)
      ..scaleTo(dragFactor)
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

    if (position.x + _halfDiagonal < game.playArea.left) {
      position.x = game.playArea.right;
    }

    if (position.x - _halfDiagonal > game.playArea.right) {
      position.x = game.playArea.left - _halfDiagonal;
    }

    if (position.y + _halfDiagonal < game.playArea.top) {
      position.y = game.playArea.bottom;
    }

    if (position.y - _halfDiagonal > game.playArea.bottom) {
      position.y = game.playArea.top - _halfDiagonal;
    }
  }

  final _nextVelocity = Vector2.zero();

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      if (other.ownerPlayerNumber == player.slotNumber) {
        return;
      }
      velocity.add(other.velocity..scale(0.2));
      other.removeFromParent();
    } else if (other is Ship && player.slotNumber < other.player.slotNumber) {
      _nextVelocity.setFrom(other.velocity.scaled(other.weightFactor));
      other.velocity.setFrom(velocity.scaled(weightFactor));
      velocity.setFrom(_nextVelocity);
    }
  }
}
