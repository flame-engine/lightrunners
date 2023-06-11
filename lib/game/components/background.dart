import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:lightrunners/game/lightrunners_game.dart';
import 'package:lightrunners/utils/delaunay.dart';
import 'package:lightrunners/utils/flame_utils.dart';
import 'package:lightrunners/utils/triangle2.dart';

final _paint = Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = 2
  ..color = const Color(0xFFCCCCCC);
const _margin = 200.0;

class Background extends PositionComponent with HasGameRef<LightRunnersGame> {
  late Rect clipArea;
  late List<Triangle2> triangles;

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);

    position = gameRef.playArea.topLeft.toVector2();
    size = gameRef.playArea.size.toVector2();
    clipArea = Vector2.zero() & size;
  }

  @override
  Future<void> onLoad() async {
    final size = gameRef.playArea.inflate(_margin).size.toVector2();
    final delta = Vector2.all(-_margin / 2);

    final fixedPointsGrid = gameRef.playArea.inflate(10.0).toFlameRectangle();
    final fixedPoints = fixedPointsGrid.vertices +
        fixedPointsGrid.edges.map(lineMidPoint).toList();
    final points = fixedPoints +
        List.generate(30, (_) {
          return Vector2.random()..multiply(size);
        });
    triangles =
        Delaunay.triangulate(points).map((e) => e.translateBy(delta)).toList();

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.clipRect(clipArea);
    for (final t in triangles) {
      canvas.drawPath(t.toPath(), _paint);
    }
  }
}
