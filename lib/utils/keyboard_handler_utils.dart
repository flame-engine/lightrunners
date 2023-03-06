import 'package:flame/extensions.dart';
import 'package:flutter/services.dart';

void readArrowLikeKeysIntoVector2(
  RawKeyEvent event,
  Set<LogicalKeyboardKey> keysPressed,
  Vector2 vector, {
  required LogicalKeyboardKey up,
  required LogicalKeyboardKey down,
  required LogicalKeyboardKey left,
  required LogicalKeyboardKey right,
}) {
  final isDown = event is RawKeyDownEvent;
  if (event.logicalKey == up) {
    if (isDown) {
      vector.y = -1;
    } else if (keysPressed.contains(down)) {
      vector.y = 1;
    } else {
      vector.y = 0;
    }
  } else if (event.logicalKey == down) {
    if (isDown) {
      vector.y = 1;
    } else if (keysPressed.contains(up)) {
      vector.y = -1;
    } else {
      vector.y = 0;
    }
  } else if (event.logicalKey == left) {
    if (isDown) {
      vector.x = -1;
    } else if (keysPressed.contains(right)) {
      vector.x = 1;
    } else {
      vector.x = 0;
    }
  } else if (event.logicalKey == right) {
    if (isDown) {
      vector.x = 1;
    } else if (keysPressed.contains(left)) {
      vector.x = -1;
    } else {
      vector.x = 0;
    }
  }
}
