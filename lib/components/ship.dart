import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter_con_game/components/bullet.dart';
import 'package:flutter_con_game/main.dart';
import 'package:flutter_con_game/utils/keyboard_handler_utils.dart';

class Ship extends PositionComponent with KeyboardHandler, HasGameRef<MyGame> {
  static final _paint = BasicPalette.cyan.paint();
  static const _engine = 25.0;
  static const _drag = 5.0;
  static const _bullet = 50.0;

  Vector2 velocity = Vector2.zero();

  Vector2 move = Vector2.zero();
  Vector2 shoot = Vector2.zero();

  @override
  Future<void> onLoad() async {
    position = gameRef.size / 2;
    size = Vector2.all(10.0);
    anchor = Anchor.center;

    add(TimerComponent(period: 0.2, repeat: true, onTick: fire));
  }

  void fire() {
    if (shoot.isZero()) {
      return;
    }
    gameRef.add(
      Bullet(
        position: position,
        velocity: shoot * _bullet,
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

    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    final dt2 = dt * dt;

    final engine = move * _engine;
    final drag = velocity.clone()
      ..scaleTo(_drag)
      ..scale(-1);
    final acc = engine + drag;

    velocity += acc * dt;
    position += velocity * dt + acc * dt2 / 2;
  }

  @override
  void render(Canvas c) {
    c.drawRect(Vector2.zero() & size, _paint);
  }
}
