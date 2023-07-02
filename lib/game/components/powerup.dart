import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/animation.dart';
import 'package:lightrunners/game/game.dart';

enum PowerUpType {
  speed('invertase.png'),
  shots('flame.png'),
  weight('globe.png');

  const PowerUpType(this.asset);

  final String asset;
}

class PowerUp extends SpriteComponent
    with HasGameReference<LightRunnersGame>, CollisionCallbacks {
  PowerUp(this.type) : super(anchor: Anchor.center);

  static final Random _random = Random();
  final PowerUpType type;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await game.loadSprite(type.asset);
    final sizeRelation = sprite!.image.width / sprite!.image.height;
    final width = 100 + 100 * _random.nextDouble();
    size = Vector2(width, sizeRelation * width);

    add(CircleHitbox()..collisionType = CollisionType.passive);
    add(
      ScaleEffect.by(
        Vector2.all(1.3),
        EffectController(duration: 1.0, alternate: true, infinite: true),
      ),
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship) {
      removeAll(children);
      affectShip(other);
      addAll(
        [
          ScaleEffect.to(Vector2.all(0), EffectController(duration: 1.0)),
          RotateEffect.by(
            tau * 3,
            EffectController(duration: 1.0, curve: Curves.elasticIn),
            onComplete: removeFromParent,
          ),
        ],
      );
    }
  }

  void affectShip(Ship ship) {
    switch(type) {
      case PowerUpType.shots:
        ship.bulletSpeed *= 2;
      case PowerUpType.speed:
        ship.engineStrength *= 2;
      case PowerUpType.weight:
        ship.weightFactor *= 2;
    }
  }
}
