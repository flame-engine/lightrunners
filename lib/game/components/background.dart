import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:lightrunners/game/lightrunners_game.dart';

const _minTriangleAngle = pi / 16;
const _epsilon = 1e-3;

class Background extends SpriteComponent with HasGameRef<LightRunnersGame> {
  // TODO(all): change from static sprite to a dynamic, living thing.
  late final Sprite background;

  @override
  Future<void> onLoad() async {
    size = gameRef.playArea.size.toVector2();
    sprite = await _generateSprite(size, 100);
  }

  Future<Sprite> _generateSprite(Vector2 size, int n) async {
    final (points, triangles) = _generateTriangularMesh(size, n);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    triangles.forEach((t) => canvas.drawPath(t.toPath(), paint));
    points.forEach((p) => canvas.renderPoint(p, size: 5));

    final picture = recorder.endRecording();
    final image = await picture.toImageSafe(
      size.x.toInt(),
      size.y.toInt(),
    );

    return Sprite(image);
  }

  (Iterable<Vector2>, List<_Triangle>) _generateTriangularMesh(
      Vector2 size, int n) {
    final allPoints = List.generate(n, (_) => Vector2.random()..multiply(size));
    final points = allPoints.whereIndexed((i, p) {
      final otherPoints = [...allPoints]..removeAt(i);
      return !_isAnyCollinear(p, otherPoints);
    }).sortedBy<num>((e) => e.x);
    print(points.length);
    final triangles = <_Triangle>[
      _Triangle(vertices: points.take(3).toList()),
    ];
    for (final p in points.skip(3)) {
      final newTriangles = triangles
          .map((e) => e.vertices.sortedBy<num>(p.distanceTo).take(2))
          .where((vs) => vs.every((v) => _canSeePoint(p, v, triangles)))
          .map((vs) => _Triangle(vertices: [p, ...vs]))
          .where((t) => t.angles.every((a) => a >= _minTriangleAngle))
          .take(1)
          .toList();
      print('adding ${newTriangles.length}');
      triangles.addAll(newTriangles);
    }
    print(triangles.length);
    return (points, triangles);
  }

  bool _isAnyCollinear(Vector2 p, Iterable<Vector2> points) {
    return points.whereIndexed((i, p1) {
      final otherPoints = [...points]..removeAt(i);
      return otherPoints.any((p2) => _isCollinear(p, p1, p2));
    }).isNotEmpty;
  }

  bool _isCollinear(Vector2 p1, Vector2 p2, Vector2 p3) {
    return (p2.y - p1.y) * (p3.x - p2.x) == (p3.y - p2.y) * (p2.x - p1.x);
  }

  bool _canSeePoint(Vector2 looker, Vector2 target, List<_Triangle> obstacles) {
    final line = LineSegment(looker, target);
    return obstacles.none((t) {
      return t
          .intersections(line)
          .any((e) => !_equal(e, target) && !_equal(e, looker));
    });
  }

  bool _equal(Vector2 v1, Vector2 v2) {
    return v1 == v2 || (v1 - v2).length < _epsilon;
  }
}

class _Triangle {
  List<Vector2> vertices;

  _Triangle({
    required this.vertices,
  });

  Vector2 _modGet(int idx) => vertices[idx % vertices.length];

  Path toPath() {
    return Path()..addPolygon(vertices.map((e) => e.toOffset()).toList(), true);
  }

  List<LineSegment> get edges => vertices.mapIndexed((i, v) {
        return LineSegment(v, _modGet(i + 1));
      }).toList();

  List<double> get angles => vertices.mapIndexed((i, v) {
        final v1 = v - _modGet(i + 1);
        final v2 = v - _modGet(i + 2);
        return v1.angleTo(v2);
      }).toList();

  List<Vector2> intersections(LineSegment line) {
    return edges.expand((e) => e.intersections(line)).toList();
  }
}
