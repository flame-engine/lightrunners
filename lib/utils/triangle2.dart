import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/experimental.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:lightrunners/utils/flame_utils.dart';

class Triangle2 {
  List<Vector2> vertices;

  Triangle2({
    required this.vertices,
  }) : assert(vertices.length == 3);

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

  bool isTriangleInside(Triangle2 other) {
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

  bool isSameAs(Triangle2 other) {
    if (this == other) {
      return true;
    }
    return vertices
        .every((v) => other.vertices.any((other) => isSameVector(v, other)));
  }

  bool isValid() {
    // check not colinear
    final v1 = vertices[0];
    final v2 = vertices[1];
    final v3 = vertices[2];

    final det = (v2.y - v3.y) * (v1.x - v3.x) + (v3.x - v2.x) * (v1.y - v3.y);
    if (det == 0) {
      return false;
    }

    // check not degenerate
    final a = v1.distanceTo(v2);
    final b = v2.distanceTo(v3);
    final c = v3.distanceTo(v1);

    return a + b > c && b + c > a && c + a > b;
  }

  Circle circumcircle() {
    return _circleFromPoints(vertices)!;
  }

  Triangle2 translateBy(Vector2 offset) {
    return Triangle2(
      vertices: vertices.map((v) => v + offset).toList(),
    );
  }

  @override
  String toString() {
    return 'Triangle2(vertices: $vertices)';
  }
}

// TODO(luan): add to Flame: Circle.fromPoints
Circle? _circleFromPoints(List<Vector2> points) {
  final p1 = points[0];
  final p2 = points[1];
  final p3 = points[2];

  final offset = pow(p2.x, 2) + pow(p2.y, 2);
  final bc = (pow(p1.x, 2) + pow(p1.y, 2) - offset) / 2.0;
  final cd = (offset - pow(p3.x, 2) - pow(p3.y, 2)) / 2.0;
  final det = (p1.x - p2.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p2.y);
  if (det == 0) {
    return null;
  }

  final centerX = (bc * (p2.y - p3.y) - cd * (p1.y - p2.y)) / det;
  final centerY = (cd * (p1.x - p2.x) - bc * (p2.x - p3.x)) / det;
  final radius = sqrt(pow(p2.x - centerX, 2) + pow(p2.y - centerY, 2));

  return Circle(Vector2(centerX, centerY), radius);
}
