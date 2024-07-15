import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';

// TODO(luan): optimize, test, and move this to Flame

const _epsilon = 10e-9;

bool isSameLine(LineSegment a, LineSegment b, {double epsilon = _epsilon}) {
  return (isSameVector(a.from, b.from, epsilon: epsilon) &&
          isSameVector(a.to, b.to, epsilon: epsilon)) ||
      (isSameVector(a.from, b.to, epsilon: epsilon) &&
          isSameVector(a.to, b.from, epsilon: epsilon));
}

bool isSameVector(Vector2 v1, Vector2 v2, {double epsilon = _epsilon}) {
  return v1.distanceToSquared(v2) < epsilon;
}

Vector2 lineMidPoint(LineSegment line) {
  return line.from + (line.to - line.from) / 2;
}
