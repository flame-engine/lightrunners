import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:lightrunners/game/components/ship.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/utils.dart';

const _spotlightRadius = 35.0;
const _spotlightSpeed = 50.0;
final _r = Random();

class Spotlight extends PositionComponent with HasGameRef<LightRunnersGame> {
  Paint paint = Paint();

  double scoringCounter = 0.0;
  Ship? currentShipRef;

  Vector2 newTarget = Vector2.zero();

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    size = Vector2.all(_spotlightRadius * 2);
    position = Vector2.zero();
    newTarget = newRandomTarget();
    paint.colorFilter = const ColorFilter.mode(
      Color(0xFFFFFFFF),
      BlendMode.lighten,
    );
    _updateColor();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    moveTowards(position, newTarget, _spotlightSpeed * dt);
    // maybe new random target
    _updateCurrentShip();
    // scoring
  }

  void _updateColor() {
    final baseColor = currentShipRef?.paint.color ?? BasicPalette.white.color;
    paint.color = baseColor.withOpacity(0.5);
  }

  void _updateCurrentShip() {
    final newShip = _decideCurrentShip();
    if (newShip != currentShipRef) {
      currentShipRef = newShip;
      scoringCounter = 0.0;
    }
    _updateColor();
  }

  Ship? _decideCurrentShip() {
    final inside = gameRef.ships.values.where((ship) {
      final distance = ship.absolutePosition.distanceTo(absolutePosition);
      return distance < _spotlightRadius;
    });
    if (inside.length == 1) {
      return inside.first;
    } else {
      return null;
    }
  }

  Vector2 newRandomTarget() {
    final rect = gameRef.playArea.deflate(_spotlightRadius);
    final x = -rect.width / 2 + _r.nextDouble() * rect.width;
    final y = -rect.height / 2 + _r.nextDouble() * rect.height;
    return Vector2(x, y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, _spotlightRadius, paint);
  }
}
