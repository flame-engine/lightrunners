import 'dart:math' hide Rectangle;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/ui.dart';
import 'package:lightrunners/utils/flame_utils.dart';

const _radius = Radius.circular(5);
const _rotationSpeed = 1.0;
final _white = BasicPalette.white.color;

class GameBorder extends PositionComponent with HasGameRef<LightRunnersGame> {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8;
  late RRect rRect;

  late Rectangle clipArea;
  late Vector2 clipAreaCenter;

  /// The phase of rotation
  double _phi = 0.0;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    position = gameRef.playArea.topLeft.toVector2();
    size = gameRef.playArea.size.toVector2();
    rRect = RRect.fromRectAndRadius(Vector2.zero() & size, _radius);

    clipArea = gameRef.playArea.inflate(200.0).toFlameRectangle();
    clipAreaCenter = clipArea.center;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _phi += dt * _rotationSpeed;
    _phi %= tau;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    for (final (color, path) in _generateBorderClips(clipArea)) {
      canvas.save();
      canvas.translateVector(clipAreaCenter);
      canvas.clipPath(path);
      canvas.translateVector(-clipAreaCenter);
      canvas.drawRRect(rRect, paint..color = color);
      canvas.restore();
    }
  }

  List<(Color, Path)> _generateBorderClips(Rectangle clipArea) {
    var ships = game.ships.values.map((ship) => (ship.paint.color, ship.score));
    // TODO(luan): remove this mock once we have more ships
    ships = [
      (GamePalette.red, 5),
      (GamePalette.green, 2),
      (GamePalette.lightBlue, 1),
    ];
    final topShips = ships.sortedBy<num>((e) => -e.$2).take(3);
    final totalScore = topShips.map((e) => e.$2).sum;
    final best = topShips.first;
    if (totalScore == best.$2) {
      return [
        (
          best.$2 == 0.0 ? _white : best.$1,
          _generateClipPath(0.0, tau, clipArea),
        ),
      ];
    }

    double normalize(double angle, double zero) {
      final n = angle % tau;
      return n == 0 ? zero : n;
    }

    var prev = _phi;
    return topShips
        .map((e) => (e.$1, tau * e.$2 / totalScore))
        .map((e) => (e.$1, prev, prev = prev + e.$2))
        .map((e) => (e.$1, normalize(e.$2, 0.0), normalize(e.$3, tau)))
        .map((e) => (e.$1, _generateClipPath(e.$2, e.$3, clipArea)))
        .toList();
  }

  Path _generateClipPath(double alpha1, double alpha2, Rectangle clipArea) {
    final cornerAngle = atan(clipArea.height / clipArea.width);
    final cornerAngles = [
      cornerAngle,
      pi - cornerAngle,
      pi + cornerAngle,
      tau - cornerAngle,
    ];
    final angles = [
      alpha1,
      // find the corners "in between" alpha1 and alpha2
      ...cornerAngles.where((e) {
        if (alpha1 <= alpha2) {
          return e > alpha1 && e < alpha2;
        } else {
          return !(e > alpha2 && e < alpha1);
        }
      }).sortedBy<num>((e) => e > alpha1 ? 0 : 1),
      alpha2,
    ];
    final clipLength = 2 * (clipArea.width + clipArea.height);
    // convert each angle to its intersection point in the clip area rectangle
    final points = angles
        .map((e) => Vector2(cos(e), sin(e))..scale(clipLength))
        .map((e) => LineSegment(Vector2.zero(), e))
        .map((e) => clipArea.intersections(e).firstOrNull)
        .nonNulls
        .map((e) => e.toOffset())
        .toList();
    return Path()..addPolygon([Offset.zero, ...points], true);
  }
}
