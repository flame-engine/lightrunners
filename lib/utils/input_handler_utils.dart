import 'package:flame/extensions.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';

const _joystickAxisMaxValue = 32767;

class GamepadJoystick {
  final String gamepadId;
  final String xAxisKey;
  final String yAxisKey;
  final Vector2 state = Vector2.zero();

  GamepadJoystick({
    required this.gamepadId,
    required this.xAxisKey,
    required this.yAxisKey,
  });

  void consume(GamepadEvent event) {
    if (event.gamepadId != gamepadId) {
      return;
    }

    var intensity = (event.value / _joystickAxisMaxValue).clamp(-1.0, 1.0);
    if (intensity.abs() < 0.2) {
      intensity = 0;
    }

    if (event.key == xAxisKey) {
      state.x = intensity;
    } else if (event.key == yAxisKey) {
      state.y = intensity;
    }
  }
}

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
