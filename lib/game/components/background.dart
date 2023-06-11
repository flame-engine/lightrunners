import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:lightrunners/game/lightrunners_game.dart';

const _minTriangleAngle = pi / 16 / 2;
const _epsilon = 1e-3;

class Background extends SpriteComponent with HasGameRef<LightRunnersGame> {
  // TODO(all): change from static sprite to a dynamic, living thing.
  late final Sprite background;

  @override
  Future<void> onLoad() async {
    size = gameRef.playArea.size.toVector2();
    sprite = await _generateSprite(size, 200);
  }

  Future<Sprite> _generateSprite(Vector2 size, int n) async {
    final (points, triangles, t2) = _generateTriangularMesh(size, n);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;

    final paint2 = Paint()
      ..color = const Color(0xFFFFFF00)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // canvas.translateVector(-size);
    triangles.forEach((t) => canvas.drawPath(t.toPath(), paint));
    t2.forEach((t) => canvas.drawPath(t.toPath(), paint2));
    points.forEach((p) => canvas.renderPoint(p, size: 5));

    final picture = recorder.endRecording();
    final image = await picture.toImageSafe(
      size.x.toInt(),
      size.y.toInt(),
    );

    return Sprite(image);
  }

  (Iterable<Vector2>, List<_Triangle>, List<_Triangle>) _generateTriangularMesh(
    Vector2 size,
    int n,
  ) {
    final allPoints = List.generate(n, (_) => Vector2.random()..multiply(size));
    final points = allPoints.whereIndexed((i, p) {
      final otherPoints = [...allPoints]..removeAt(i);
      return !_isAnyCollinear(p, otherPoints);
    }).sortedBy<num>((e) => e.x);
    final triangles = _buildTriangleBorder(size);
    final t2s = <_Triangle>[];
    for (final p in points) {
      final potentialTriangles = triangles
          .sortedBy<num>((e) => e.centroid.distanceTo(p))
          .map((e) => e.vertices.sortedBy<num>(p.distanceTo).take(2))
          .where((vs) => vs.every((v) => _canSeePoint(p, v, triangles)))
          .map((vs) => _Triangle(vertices: [p, ...vs]))
          .toList();
      final newTriangles = potentialTriangles
          .where((t) => t.angles.every((a) => a >= _minTriangleAngle))
          // .where((t) => triangles.none((existing) => !_overlaps(t, existing)))
          .take(3)
          .toList();
      t2s.addAll(potentialTriangles);
      triangles.addAll(newTriangles);
    }
    return (points, triangles, []); // t2s);
  }

  List<_Triangle> _buildTriangleBorder(Vector2 size) {
    const n = 10;
    final p1s = List.generate(n, (idx) => idx * size.y / n)
        .map((e) => Vector2(0, e))
        .toList();
    final p2s = List.generate(n - 1, (idx) => (idx + 0.5) * size.y / n)
        .map((e) => Vector2(20, e))
        .toList();
    return [
      for (var i = 0; i < n - 1; i++)
        _Triangle(vertices: [p1s[i], p2s[i], p1s[i + 1]])
    ];
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

  bool _overlaps(_Triangle t1, _Triangle t2) {
    return t1.isTriangleInside(t2) || t2.isTriangleInside(t1);
  }
}

class _Triangle {
  List<Vector2> vertices;

  _Triangle({
    required this.vertices,
  });

  Vector2 get v1 => vertices[0];
  Vector2 get v2 => vertices[1];
  Vector2 get v3 => vertices[2];

  Vector2 get centroid {
    return vertices.reduce((v1, v2) => v1 + v2)..scale(1 / vertices.length);
  }

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

  double _sign(Vector2 p1, Vector2 p2, Vector2 p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
  }

  bool isTriangleInside(_Triangle other) {
    return other.vertices.any(containsPoint);
  }

  bool containsPoint(Vector2 p) {
    final d1 = _sign(p, v1, v2);
    final d2 = _sign(p, v2, v3);
    final d3 = _sign(p, v3, v1);

    final anyNegative = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final anyPositive = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(anyNegative && anyPositive);
  }
}
