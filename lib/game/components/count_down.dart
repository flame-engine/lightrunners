import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/ui/ui.dart';

const _matchLength = 60.0;
const _radius = Radius.circular(3.0);

class CountDown extends PositionComponent {
  CountDown({
    required this.onTimeUp,
  }) : super(position: Vector2.all(32));

  final _textPosition = Vector2(20, 15);
  late RRect rRect;
  late TextPaint textPaint;
  final rectPaint = Paint()..color = GamePalette.black.withOpacity(0.5);
  final VoidCallback onTimeUp;
  late final Timer timer;

  TextPaint _makeTextPaint() {
    return TextPaint(
      style: TextStyle(
        fontFamily: GoogleFonts.bungee().fontFamily,
        fontSize: 18,
        color: GamePalette.white,
      ),
    );
  }

  @override
  void onLoad() {
    textPaint = _makeTextPaint();
    final timerComponent = TimerComponent(
      period: _matchLength,
      onTick: onTimeUp,
    );
    timer = timerComponent.timer;
    add(timerComponent);

    rRect = RRect.fromRectAndRadius(Vector2.zero() & Vector2(180, 50), _radius);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(rRect, rectPaint);

    textPaint.render(
      canvas,
      'Time Left: ${(_matchLength - timer.current).floor()}',
      _textPosition,
    );
  }
}
