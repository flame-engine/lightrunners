import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/ui.dart';

const _radius = Radius.circular(5);

// TODO(luan): style this
final _paint = Paint()
  ..color = GamePalette.pink 
  ..style = PaintingStyle.stroke
  ..strokeWidth = 4;

class GameBorder extends PositionComponent with HasGameRef<LightRunnersGame> {
  late RRect rRect;

  @override
  Future<void> onLoad() async {
    position = gameRef.playArea.topLeft.toVector2();
    size = gameRef.playArea.size.toVector2();
    rRect = RRect.fromRectAndRadius(Vector2.zero() & size, _radius);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(rRect, _paint);
  }
}
