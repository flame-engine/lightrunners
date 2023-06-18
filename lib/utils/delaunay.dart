import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:lightrunners/utils/flame_utils.dart';
import 'package:lightrunners/utils/triangle2.dart';

/// Uses the Bowyer-Watson algorithm to compute the Delaunay triangulation of
/// a given set of points.
class Delaunay {
  static List<Triangle2> triangulate(List<Vector2> vertices) {
    final superTriangle = _computeSuperTriangle(vertices);

    var triangles = [superTriangle];

    vertices.forEach((vertex) {
      triangles = _addVertex(vertex, triangles);
    });

    return triangles.where((t) {
      return !t.vertices.any((v) {
        return superTriangle.vertices.any((other) => isSameVector(v, other));
      });
    }).toList();
  }

  static List<Triangle2> _addVertex(Vector2 vertex, List<Triangle2> triangles) {
    var edges = <LineSegment>[];

    // Remove triangles with circumcircles containing the vertex
    final newTriangles = triangles.where((triangle) {
      if (triangle.circumcircle().containsPoint(vertex)) {
        edges.addAll(triangle.edges);
        return false;
      }
      return true;
    }).toList();

    edges = _uniqueEdges(edges);

    edges.forEach((edge) {
      newTriangles.add(Triangle2(vertices: [edge.from, edge.to, vertex]));
    });

    return newTriangles;
  }

  static List<LineSegment> _uniqueEdges(List<LineSegment> edges) {
    final uniqueEdges = <LineSegment>[];
    for (var i = 0; i < edges.length; ++i) {
      var isUnique = true;

      // See if edge is unique
      for (var j = 0; j < edges.length; ++j) {
        if (i != j && isSameLine(edges[i], edges[j])) {
          isUnique = false;
          break;
        }
      }

      // Edge is unique, add to unique edges array
      if (isUnique) {
        uniqueEdges.add(edges[i]);
      }
    }

    return uniqueEdges;
  }

  static Triangle2 _computeSuperTriangle(List<Vector2> points) {
    final minX = points.map((p) => p.x).reduce((a, b) => a < b ? a : b);
    final minY = points.map((p) => p.y).reduce((a, b) => a < b ? a : b);
    final maxX = points.map((p) => p.x).reduce((a, b) => a > b ? a : b);
    final maxY = points.map((p) => p.y).reduce((a, b) => a > b ? a : b);

    final dx = maxX - minX;
    final dy = maxY - minY;
    final deltaMax = dx > dy ? dx : dy;
    final midX = (minX + maxX) / 2;
    final midY = (minY + maxY) / 2;

    return Triangle2(
      vertices: [
        Vector2(midX - 20 * deltaMax, midY - deltaMax),
        Vector2(midX, midY + 20 * deltaMax),
        Vector2(midX + 20 * deltaMax, midY - deltaMax),
      ],
    );
  }
}
