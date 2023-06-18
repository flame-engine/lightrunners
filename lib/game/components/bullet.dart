import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:lightrunners/game/game.dart';

class Bullet extends CircleComponent with HasGameReference<LightRunnersGame> {
  final int ownerPlayerNumber;
  final Vector2 velocity;
  final Color color;

  static const _radius = 8.0;

  Bullet({
    required this.ownerPlayerNumber,
    required super.position,
    required this.velocity,
    required this.color,
  }) : super(
          radius: _radius,
          anchor: Anchor.center,
          paint: Paint()
            ..color = color
            ..maskFilter = const MaskFilter.blur(
              BlurStyle.normal,
              _radius / 2,
            ),
        );

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

    if (!game.playArea.contains(position.toOffset())) {
      removeFromParent();
    }
  }
}
