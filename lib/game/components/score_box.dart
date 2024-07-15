import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/game/components/ship.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/constants.dart';

const _radius = Radius.circular(3.0);

Paint _makePaint(Color color) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;
}

TextPaint _makeTextPaint(Color color) {
  return TextPaint(
    style: TextStyle(
      fontFamily: GoogleFonts.bungee().fontFamily,
      fontSize: 52,
      color: color,
    ),
  );
}

class ScoreBox extends PositionComponent
    with HasGameReference<LightRunnersGame> {
  late RRect rRect;
  final TextPaint textPaint;
  final Paint paint;
  final Vector2 targetPosition;
  final Ship shipRef;

  ScoreBox({
    required this.shipRef,
    required super.position,
  })  : paint = _makePaint(shipRef.paint.color),
        textPaint = _makeTextPaint(shipRef.paint.color),
        targetPosition = position!;

  @override
  void onLoad() {
    final availableHeight = game.size.y - 2 * screenMargin;
    size = Vector2(scoreBoxWidth, availableHeight / maxShips - scoreBoxMargin);
    rRect = RRect.fromRectAndRadius(Vector2(scoreBoxMargin, 0) & size, _radius);
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
    textPaint.render(
      canvas,
      shipRef.score.toString(),
      size / 2,
      anchor: Anchor.center,
    );
  }
}
