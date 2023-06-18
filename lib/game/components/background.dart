import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/delaunay.dart';
import 'package:lightrunners/utils/flame_utils.dart';
import 'package:lightrunners/utils/triangle2.dart';

const _margin = 200.0;

const _numberShades = 5;
const _shadeStep = 0.1;
const _colorMoveSpeed = 30;
final _emptyColor = GamePalette.black.brighten(_numberShades * _shadeStep);

final _r = Random();

typedef ShadedTriangle = ({
  Triangle2 triangle,
  int shadeLevel,
});

class Background extends PositionComponent with HasGameRef<LightRunnersGame> {
  late Rect clipArea;
  late List<ShadedTriangle> mesh;

  Color currentColor = _emptyColor;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    position = gameRef.playArea.topLeft.toVector2();
    size = gameRef.playArea.size.toVector2();
    clipArea = Vector2.zero() & size;
  }

  @override
  void onLoad() {
    final size = gameRef.playArea.inflate(_margin).size.toVector2();
    final delta = Vector2.all(-_margin / 2);

    final fixedPointsGrid = gameRef.playArea.inflate(10.0).toFlameRectangle();
    final fixedPoints = fixedPointsGrid.vertices +
        fixedPointsGrid.edges.map(lineMidPoint).toList();
    final points = fixedPoints +
        List.generate(30, (_) {
          return Vector2.random()..multiply(size);
        });
    mesh = Delaunay.triangulate(points)
        .map((e) => e.translateBy(delta))
        .map(
          (triangle) => (
            triangle: triangle,
            shadeLevel: _r.nextInt(_numberShades),
          ),
        )
        .toList();
  }

  @override
  void update(double dt) {
    super.update(dt);

    final targetColor = _computeTargetColor();
    currentColor =
        _moveTowards(currentColor, targetColor, _colorMoveSpeed * dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.clipRect(clipArea);

    for (final t in mesh) {
      final shadedColor = currentColor.darken(t.shadeLevel * _shadeStep);
      final path = t.triangle.toPath();
      canvas.drawPath(path, Paint()..color = shadedColor);
    }
  }

  (int, int, int) _computeTargetColor() {
    final sortedShips =
        gameRef.ships.values.sortedBy<num>((ship) => -ship.score);
    final maxScore = sortedShips.first.score;
    if (maxScore == 0) {
      return _fromColor(_emptyColor);
    }
    const defaultBrightening = _numberShades / 2 * _shadeStep;
    final colors = sortedShips
        .takeWhile((ship) => ship.score == maxScore)
        .map((ship) => ship.paint.color.brighten(defaultBrightening))
        .toList();
    return colors.map(_fromColor).reduce((value, element) => value + element) /
        colors.length.toDouble();
  }

  Color _moveTowards(Color currentColor, (int, int, int) target, double ds) {
    final color = _fromColor(currentColor);
    if (color == target) {
      return currentColor;
    }
    return color.moveTowards(target, ds).toColor();
  }
}

extension on (int, int, int) {
  Color toColor() => Color.fromARGB(255, $1, $2, $3);

  (int, int, int) operator +((int, int, int) other) =>
      (this.$1 + other.$1, this.$2 + other.$2, this.$3 + other.$3);

  (int, int, int) operator -((int, int, int) other) => this + (-other);

  (int, int, int) operator /(double other) =>
      _fromDoubles(this.$1 / other, this.$2 / other, this.$3 / other);

  (int, int, int) operator *(double other) =>
      _fromDoubles(this.$1 * other, this.$2 * other, this.$3 * other);

  (int, int, int) operator -() => (-this.$1, -this.$2, -this.$3);

  double get length => sqrt($1 * $1 + $2 * $2 + $3 * $3);

  (int, int, int) normalized() => this / length;

  (int, int, int) moveTowards((int, int, int) target, double ds) {
    final diff = target - this;
    if (diff.length < ds) {
      return target;
    } else {
      return this + diff.normalized() * ds;
    }
  }
}

(int, int, int) _fromDoubles(double r, double g, double b) =>
    (r.round(), g.round(), b.round());

(int, int, int) _fromColor(Color color) => (color.red, color.green, color.blue);
