import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:flutter_con_game/main.dart';

class Bullet extends CircleComponent with HasGameReference<MyGame> {
  static final _paint = BasicPalette.white.paint();
  final int ownerPlayerNumber;
  final Vector2 velocity;

  Bullet({
    required this.ownerPlayerNumber,
    required super.position,
    required this.velocity,
  }) : super(radius: 2.0, anchor: Anchor.center, paint: _paint);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox()..collisionType = CollisionType.passive);
  }

  final _velocityTmp = Vector2.zero();

  @override
  void update(double dt) {
    _velocityTmp
      ..setFrom(velocity)
      ..scale(dt);
    position.add(_velocityTmp);
    if (!game.cameraComponent.canSee(this)) {
      removeFromParent();
    }
  }
}
