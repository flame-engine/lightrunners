import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_con_game/game/components/ship.dart';
import 'package:flutter_con_game/game/lightrunners_game.dart';
import 'package:flutter_con_game/utils/constants.dart';

const _radius = Radius.circular(3.0);

Paint _makePaint(Color color) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
}

class ScoreBox extends PositionComponent with HasGameRef<LightRunnersGame> {
  late RRect rRect;
  final Paint paint;
  final Vector2 targetPosition;
  final Ship shipRef;

  ScoreBox({
    required this.shipRef,
    required this.targetPosition,
  })  : paint = _makePaint(shipRef.paint.color),
        super(position: targetPosition.clone());

  @override
  FutureOr<void> onLoad() async {
    final availableHeight = gameRef.size.y - 2 * screenMargin;
    size = Vector2(scoreBoxWidth, availableHeight / maxShips - scoreBoxMargin);
    rRect = RRect.fromRectAndRadius(Vector2.zero() & size, _radius);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    // TODO(luan): add moving transition
    position.setFrom(targetPosition);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(rRect, paint);
  }
}
