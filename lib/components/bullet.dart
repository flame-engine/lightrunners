import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';

class Bullet extends PositionComponent with HasGameRef {
  static final _paint = BasicPalette.white.paint();
  Vector2 velocity;

  Bullet({
    required super.position,
    required this.velocity,
  });

  @override
  Future<void> onLoad() async {
    size = Vector2.all(3.0);
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    if (!gameRef.size.toRect().containsPoint(position)) {
      gameRef.remove(this);
    }
  }

  @override
  void render(Canvas c) {
    c.drawRect(Vector2.zero() & size, _paint);
  }
}
