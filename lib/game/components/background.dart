import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';

const _radius = Radius.circular(5);

class Background extends PositionComponent with HasGameRef<LightRunnersGame> {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;
  late RRect rRect;

  late Rectangle clipArea;
  late Vector2 clipAreaCenter;

  // TODO(all): change from static sprite to a dynamic, living thing.
  late final Sprite background;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    position = gameRef.playArea.topLeft.toVector2();
    size = gameRef.playArea.size.toVector2();
    rRect = RRect.fromRectAndRadius(Vector2.zero() & size, _radius);
  }

  @override
  Future<void> onLoad() async {
    background = await gameRef.loadSprite('bg.png');

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    background.render(canvas, size: size);
  }
}
