import 'package:flame/extensions.dart';

class MutableColor {
  final Vector3 rgb;

  double get r => rgb.x;
  set r(double value) => rgb.x = value;

  double get g => rgb.y;
  set g(double value) => rgb.y = value;

  double get b => rgb.z;
  set b(double value) => rgb.z = value;

  MutableColor(double r, double g, double b) : rgb = Vector3(r, g, b);

  MutableColor.fromColor(Color color)
      : this(
          color.red.toDouble(),
          color.green.toDouble(),
          color.blue.toDouble(),
        );

  Color toColor() => Color.fromARGB(255, r.round(), g.round(), b.round());

  MutableColor operator +(MutableColor other) {
    return MutableColor(r + other.r, g + other.g, b + other.b);
  }

  MutableColor operator /(double scalar) {
    return MutableColor(r / scalar, g / scalar, b / scalar);
  }

  void moveTowards(MutableColor target, double ds) {
    r = _moveTowards(r, target.r, ds);
    g = _moveTowards(g, target.g, ds);
    b = _moveTowards(b, target.b, ds);
  }

  double _moveTowards(double current, double target, double ds) {
    final diff = target - current;
    if (diff.abs() < ds) {
      return target;
    } else {
      return current + ds * diff.sign;
    }
  }
}
