import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:lightrunners/game/components/ship.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/utils.dart';

const _spotlightRadius = 35.0; //pixels
const _spotlightSpeed = 50.0; // pixels per second
const _targetChangeProbability = 0.05; // per [_targetChangePeriod]
const _targetChangePeriod = 0.5; // seconds
final _random = Random();

class Spotlight extends PositionComponent
    with HasGameReference<LightRunnersGame>, HasPaint {
  Spotlight()
      : super(
          size: Vector2.all(_spotlightRadius * 2),
          anchor: Anchor.center,
        );

  double scoringCounter = 0.0;
  Ship? currentShipRef;

  final Vector2 target = Vector2.zero();
  final _renderPosition = Vector2.all(_spotlightRadius).toOffset();
  double targetChangeCounter = 0.0;

  @override
  Future<void> onLoad() async {
    updateRandomTarget();
    _updateColor();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _maybeUpdateTarget(dt);
    moveTowards(position, target, _spotlightSpeed * dt);

    _updateCurrentShip();
    _computeScoring(dt);
  }

  void _maybeUpdateTarget(double dt) {
    targetChangeCounter += dt;
    while (targetChangeCounter > _targetChangePeriod) {
      targetChangeCounter -= _targetChangePeriod;
      if (_random.nextDouble() <= _targetChangeProbability) {
        updateRandomTarget();
      }
    }
  }

  void _computeScoring(double dt) {
    scoringCounter += dt;
    while (scoringCounter > 1.0) {
      scoringCounter -= 1.0;
      currentShipRef?.score++;
    }
  }

  void _updateColor() {
    final baseColor = currentShipRef?.paint.color ?? BasicPalette.white.color;
    paint.color = baseColor.withOpacity(0.5);
  }

  void _updateCurrentShip() {
    final newShip = _decideCurrentShip();
    if (newShip?.playerNumber != currentShipRef?.playerNumber) {
      currentShipRef = newShip;
      scoringCounter = 0.0;
    }
    _updateColor();
  }

  Ship? _decideCurrentShip() {
    final inside = game.ships.values.where((ship) {
      final distance = ship.absolutePosition.distanceTo(absolutePosition);
      return distance < _spotlightRadius;
    });
    if (inside.length == 1) {
      return inside.first;
    } else {
      return null;
    }
  }

  void updateRandomTarget() {
    final rect = game.playArea.deflate(_spotlightRadius);
    final x = -rect.width / 2 + _random.nextDouble() * rect.width;
    final y = -rect.height / 2 + _random.nextDouble() * rect.height;
    target.setValues(x, y);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(
      _renderPosition,
      _spotlightRadius,
      paint,
    );
  }
}
