import 'package:flame/extensions.dart';

void moveTowards(Vector2 pos, Vector2 target, double ds) {
  final diff = target - pos;
  if (diff.length < ds) {
    pos.setFrom(target);
  } else {
    pos.add(diff.normalized() * ds);
  }
}
