import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
import 'package:lightrunners/game/components/ship.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/utils.dart';

const _spotlightRadius = 45.0; // pixels
const _spotlightSpeed = 50.0; // pixels per second
const _targetChangeProbability = 0.05; // per [_targetChangePeriod]
const _targetChangePeriod = 0.5; // seconds
final _random = Random();

class Spotlight extends CircleComponent
    with HasGameReference<LightRunnersGame>, CollisionCallbacks {
  Spotlight() : super(radius: _spotlightRadius, anchor: Anchor.center);

  final List<Ship> currentShips = [];
  Ship? get activeShip => currentShips.length == 1 ? currentShips.first : null;

  late final TimerComponent _scoreTimer;
  late final Rect _visibleArea;

  final Vector2 target = Vector2.zero();
  double targetChangeCounter = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    paint = Paint()
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        radius / 10,
      );
    _scoreTimer = TimerComponent(
      period: 0.5,
      repeat: true,
      autoStart: false,
      onTick: () => currentShips.firstOrNull?.score++,
    );
    _visibleArea = game.playArea.deflate(_spotlightRadius);
    addAll([
      CircleHitbox(
        isSolid: true,
        collisionType: CollisionType.passive,
      ),
      _scoreTimer
    ]);
    _updateRandomTarget();
    _updateColor();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _maybeUpdateTarget(dt);
    moveTowards(position, target, _spotlightSpeed * dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ship) {
      currentShips.add(other);
    }
    _updateColor();
    _updateTimerState();
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    currentShips.remove(other);
    _updateColor();
    _updateTimerState();
  }

  void _updateTimerState() {
    if (currentShips.length == 1) {
      _scoreTimer.timer.start();
    } else {
      _scoreTimer.timer.stop();
    }
  }

  void _updateRandomTarget() {
    target.setValues(
      -_visibleArea.width / 2 + _random.nextDouble() * _visibleArea.width,
      -_visibleArea.height / 2 + _random.nextDouble() * _visibleArea.height,
    );
  }

  void _maybeUpdateTarget(double dt) {
    targetChangeCounter += dt;
    while (targetChangeCounter > _targetChangePeriod) {
      targetChangeCounter -= _targetChangePeriod;
      if (_random.nextDouble() <= _targetChangeProbability) {
        _updateRandomTarget();
      }
    }
  }

  void _updateColor() {
    final baseColor = activeShip?.paint.color ?? BasicPalette.white.color;
    paint.color = baseColor.withOpacity(0.5);
  }
}
