import 'dart:math';

import 'package:flame/extensions.dart';

const tau = 2 * pi;

void moveTowards(Vector2 pos, Vector2 target, double ds) {
  final diff = target - pos;
  if (diff.length < ds) {
    pos.setFrom(target);
  } else {
    pos.add(diff.normalized() * ds);
  }
}
