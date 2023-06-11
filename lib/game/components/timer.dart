import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/ui/ui.dart';

const _matchLength = 60;
const _radius = Radius.circular(3.0);

class Timer extends PositionComponent {
  Timer({
    required this.onTimeUp,
  }) : super(position: Vector2.all(32));

  final _textPosition = Vector2(20, 15);
  int _timeLeft = _matchLength;
  late RRect rRect;
  late TextPaint textPaint;
  final rectPaint = Paint()..color = GamePalette.black.withOpacity(0.5);
  final VoidCallback onTimeUp;

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
  Future<void> onLoad() async {
    await super.onLoad();

    textPaint = _makeTextPaint();

    add(
      TimerComponent(
        period: 1,
        repeat: true,
        onTick: _onTick,
      ),
    );

    rRect = RRect.fromRectAndRadius(Vector2.zero() & Vector2(180, 50), _radius);
  }

  void _onTick() {
    if (_timeLeft == 0) {
      onTimeUp();
    } else {
      _timeLeft--;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRRect(rRect, rectPaint);

    textPaint.render(
      canvas,
      'Time Left: $_timeLeft',
      _textPosition,
    );
  }
}
