import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:lightrunners/game/game.dart';
import 'package:lightrunners/ui/ui.dart';

const bulletRadius = 8.0;

class Bullet extends CircleComponent with HasGameReference<LightRunnersGame> {
  final int ownerPlayerNumber;
  final Vector2 velocity;
  final Color color;

  Bullet({
    required this.ownerPlayerNumber,
    required super.position,
    required this.velocity,
    required this.color,
  }) : super(
          radius: bulletRadius,
          anchor: Anchor.center,
          paint: GamePalette.bulletPaints[ownerPlayerNumber],
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

    final playArea = game.playArea;
    if (position.x > playArea.width || position.y > playArea.height) {
      removeFromParent();
    }
  }
}
