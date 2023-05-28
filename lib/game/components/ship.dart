import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/utils/input_handler_utils.dart';

final _shipColors = [
  BasicPalette.green.paint(),
  BasicPalette.cyan.paint(),
  BasicPalette.red.paint(),
];

GamepadJoystick? _makeJoystick(String? gamepadId, String xAxis, String yAxis) {
  if (gamepadId == null) {
    return null;
  }
  return GamepadJoystick(
    gamepadId: gamepadId,
    xAxisKey: xAxis,
    yAxisKey: yAxis,
  );
}

class Ship extends RectangleComponent
    with
        KeyboardHandler,
        HasGameReference<LightRunnersGame>,
        CollisionCallbacks {
  static const _engine = 125.0;
  static const _drag = 5.0;
  static const _bulletSpeed = 300.0;

  Ship(this.playerNumber, this.gamepadId)
      : moveJoystick = _makeJoystick(gamepadId, '0', '1'),
        shootJoystick = _makeJoystick(gamepadId, '3', '4'),
        super(
          size: Vector2.all(10),
          anchor: Anchor.center,
          paint: _shipColors[playerNumber],
        );

  final int playerNumber;
  final String? gamepadId; // null means keyboard
  int score = 0;

  final Vector2 velocity = Vector2.zero();
  final Vector2 drag = Vector2.zero();
  final Vector2 engine = Vector2.zero();
  final Vector2 acceleration = Vector2.zero();

  final GamepadJoystick? moveJoystick;
  final GamepadJoystick? shootJoystick;
  final Vector2 move = Vector2.zero();
  final Vector2 shoot = Vector2.zero();

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
    add(TimerComponent(period: 0.2, repeat: true, onTick: fire));
  }

  void fire() {
    if (shoot.isZero()) {
      return;
    }
    game.world.add(
      Bullet(
        ownerPlayerNumber: playerNumber,
        position: position + (shoot..scaled(size.length2)),
        velocity: shoot * _bulletSpeed,
      ),
    );
  }

  @override
  bool onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    readArrowLikeKeysIntoVector2(
      event,
      keysPressed,
      move,
      up: LogicalKeyboardKey.keyW,
      left: LogicalKeyboardKey.keyA,
      down: LogicalKeyboardKey.keyS,
      right: LogicalKeyboardKey.keyD,
    );

    readArrowLikeKeysIntoVector2(
      event,
      keysPressed,
      shoot,
      up: LogicalKeyboardKey.arrowUp,
      left: LogicalKeyboardKey.arrowLeft,
      down: LogicalKeyboardKey.arrowDown,
      right: LogicalKeyboardKey.arrowRight,
    );

    return false;
  }

  void onGamepadEvent(GamepadEvent event) {
    _handleGamepadAxisInput(moveJoystick, event, move);
    _handleGamepadAxisInput(shootJoystick, event, shoot);
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
    super.update(dt);

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
