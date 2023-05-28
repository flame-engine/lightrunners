import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter_con_game/game/lightrunners_game.dart';
import 'package:flutter_con_game/utils/utils.dart';

const _spotlightRadius = 35.0;
const _spotlightSpeed = 50.0;
final _r = Random();

class Spotlight extends PositionComponent with HasGameRef<LightRunnersGame> {
  static final _paint = Paint()..color = const Color(0x8800FFFF);

  Vector2 newTarget = Vector2.zero();

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = Vector2.all(_spotlightRadius * 2);
    position = gameRef.playArea.center.toVector2();
    newTarget = newRandomTarget();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    moveTowards(position, newTarget, _spotlightSpeed * dt);
    // maybe new random target
    // scoring
  }

  Vector2 newRandomTarget() {
    final rect = gameRef.playArea.deflate(_spotlightRadius);
    final x = _r.nextDouble() * rect.width;
    final y = _r.nextDouble() * rect.height;
    return rect.topLeft.toVector2() + Vector2(x, y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, _spotlightRadius, _paint);
  }
}
