import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:flutter_con_game/main.dart';

class Ship extends PositionComponent with KeyboardHandler, HasGameRef<MyGame> {
  static final _paint = BasicPalette.white.paint();

  Vector2 velocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    position = gameRef.size / 2;
    size = Vector2.all(3.0);
    anchor = Anchor.center;

    velocity = Vector2(0, -10);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    position += velocity * dt;
  }

  @override
  void render(Canvas c) {
    c.drawRect(Vector2.zero() & size, _paint);
  }
}
