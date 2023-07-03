import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/delaunay.dart';
import 'package:lightrunners/utils/flame_utils.dart';

const _margin = 200.0;

const _numberShades = 5;
const _shadeStep = 0.1;
const _colorMoveSpeed = 30;
final _emptyColor = GamePalette.black.brighten(0.1);

final _random = Random();

typedef ShadedTriangle = ({
  Path path,
  int shadeLevel,
});

class Background extends PositionComponent
    with HasGameReference<LightRunnersGame>, HasPaint {
  late Rect clipArea;
  late List<ShadedTriangle> mesh;

  Color currentColor = _emptyColor;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    position = game.playArea.topLeft.toVector2();
    size = game.playArea.size.toVector2();
    clipArea = Vector2.zero() & size;
  }

  @override
  void onLoad() {
    final size = game.playArea.inflate(_margin).size.toVector2();
    final delta = Vector2.all(-_margin / 2);

    final fixedPointsGrid = game.playArea.inflate(10.0).toFlameRectangle();
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
            path: triangle.toPath(),
            shadeLevel: _random.nextInt(_numberShades),
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
      final shadedColor = currentColor.brighten(t.shadeLevel * _shadeStep);
      canvas.drawPath(t.path, paint..color = shadedColor);
    }
  }

  (int, int, int) _computeTargetColor() {
    final sortedShips = game.ships.values.sortedBy<num>((ship) => -ship.score);
    final maxScore = sortedShips.first.score;
    if (maxScore == 0) {
      return _fromColor(_emptyColor);
    }
    final colors = sortedShips
        .takeWhile((ship) => ship.score == maxScore)
        .map((ship) => ship.paint.color.darken(0.75))
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
