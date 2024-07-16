import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/delaunay.dart';
import 'package:lightrunners/utils/flame_utils.dart';
import 'package:lightrunners/utils/mutable_color.dart';

const _margin = 200.0;

const _numberShades = 5;
const _shadeStep = 0.1;
const _colorMoveSpeed = 0.8;
final _emptyColor = GamePalette.black.brighten(0.1);
final _borderPaint = Paint()
  ..color = GamePalette.black
  ..strokeWidth = 2
  ..style = PaintingStyle.stroke
  ..filterQuality = FilterQuality.high;

final _random = Random();

typedef ShadedTriangle = ({
  Path path,
  int shadeLevel,
});

class Background extends PositionComponent
    with HasGameReference<LightRunnersGame>, HasPaint {
  late Rect clipArea;
  late List<ShadedTriangle> mesh;

  MutableColor currentColor = MutableColor.fromColor(_emptyColor);

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
    currentColor.moveTowards(targetColor, _colorMoveSpeed * dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.clipRect(clipArea);

    for (final t in mesh) {
      final shadedColor =
          currentColor.toColor().brighten(t.shadeLevel * _shadeStep);
      canvas.drawPath(t.path, paint..color = shadedColor);
    }

    for (final t in mesh) {
      canvas.drawPath(t.path, _borderPaint);
    }
  }

  MutableColor _computeTargetColor() {
    final sortedShips = game.ships.values.sortedBy<num>((ship) => -ship.score);
    final maxScore = sortedShips.first.score;
    if (maxScore == 0) {
      return MutableColor.fromColor(_emptyColor);
    }
    final colors = sortedShips
        .takeWhile((ship) => ship.score == maxScore)
        .map((ship) => ship.paint.color.darken(0.75))
        .toList();
    return colors
            .map(MutableColor.fromColor)
            .reduce((value, element) => value + element) /
        colors.length.toDouble();
  }
}
