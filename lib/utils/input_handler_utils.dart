import 'package:flame/extensions.dart';
import 'package:flutter/services.dart';
import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/utils/gamepad_map.dart';

class GamepadJoystick {
  final String gamepadId;
  final GamepadKey xAxisKey;
  final GamepadKey yAxisKey;
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

    final intensity = GamepadAnalogAxis.normalizedIntensity(event);

    if (xAxisKey.matches(event)) {
      state.x = intensity;
    } else if (yAxisKey.matches(event)) {
      state.y = intensity;
    }
  }
}

bool readArrowLikeKeysIntoVector2(
  KeyEvent event,
  Set<LogicalKeyboardKey> keysPressed,
  Vector2 vector, {
  required LogicalKeyboardKey up,
  required LogicalKeyboardKey down,
  required LogicalKeyboardKey left,
  required LogicalKeyboardKey right,
}) {
  final isDown = event is KeyDownEvent;
  if (event.logicalKey == up) {
    if (isDown) {
      vector.y = -1;
    } else if (keysPressed.contains(down)) {
      vector.y = 1;
    } else {
      vector.y = 0;
    }
    return false;
  } else if (event.logicalKey == down) {
    if (isDown) {
      vector.y = 1;
    } else if (keysPressed.contains(up)) {
      vector.y = -1;
    } else {
      vector.y = 0;
    }
    return false;
  } else if (event.logicalKey == left) {
    if (isDown) {
      vector.x = -1;
    } else if (keysPressed.contains(right)) {
      vector.x = 1;
    } else {
      vector.x = 0;
    }
    return false;
  } else if (event.logicalKey == right) {
    if (isDown) {
      vector.x = 1;
    } else if (keysPressed.contains(left)) {
      vector.x = -1;
    } else {
      vector.x = 0;
    }
    return false;
  }
  return true;
}

extension IsKeyPressed on KeyEvent {
  bool isKeyPressed(LogicalKeyboardKey logicalKey) {
    return this is KeyDownEvent && this.logicalKey == logicalKey;
  }
}
