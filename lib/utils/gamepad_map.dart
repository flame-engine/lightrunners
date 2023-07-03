import 'dart:io';

import 'package:gamepads/gamepads.dart';

const _joystickAxisMaxValueLinux = 32767;

abstract class GamepadKey {
  const GamepadKey();

  bool matches(GamepadEvent event);
}

class GamepadAnalogAxis implements GamepadKey {
  final String linuxKeyName;
  final String macosKeyName;

  const GamepadAnalogAxis({
    required this.linuxKeyName,
    required this.macosKeyName,
  });

  @override
  bool matches(GamepadEvent event) {
    final key = event.key;
    final isKey = key == linuxKeyName || key == macosKeyName;
    return isKey && event.type == KeyType.analog;
  }

  static double normalizedIntensity(GamepadEvent event) {
    final intensity = Platform.isMacOS
        ? event.value
        : (event.value / _joystickAxisMaxValueLinux).clamp(-1.0, 1.0);

    if (intensity.abs() < 0.2) {
      return 0;
    }
    return intensity;
  }
}

class GamepadButtonKey extends GamepadKey {
  final String linuxKeyName;
  final String macosKeyName;

  const GamepadButtonKey({
    required this.linuxKeyName,
    required this.macosKeyName,
  });

  @override
  bool matches(GamepadEvent event) {
    final isKey = event.key == linuxKeyName || event.key == macosKeyName;
    return isKey && event.value == 1.0 && event.type == KeyType.button;
  }
}

class GamepadBumperKey extends GamepadKey {
  final String key;

  const GamepadBumperKey({required this.key});

  @override
  bool matches(GamepadEvent event) {
    return event.key == key &&
        event.value > 10000 &&
        event.type == KeyType.analog;
  }
}

const leftXAxis = GamepadAnalogAxis(
  linuxKeyName: '0',
  macosKeyName: 'l.joystick - xAxis',
);
const leftYAxis = GamepadAnalogAxis(
  linuxKeyName: '1',
  macosKeyName: 'l.joystick - yAxis',
);
const rightXAxis = GamepadAnalogAxis(
  linuxKeyName: '3',
  macosKeyName: 'r.joystick - xAxis',
);
const rightYAxis = GamepadAnalogAxis(
  linuxKeyName: '4',
  macosKeyName: 'r.joystick - yAxis',
);

const GamepadKey aButton = GamepadButtonKey(
  linuxKeyName: '0',
  macosKeyName: 'a.circle',
);
const GamepadKey bButton = GamepadButtonKey(
  linuxKeyName: '???',
  macosKeyName: 'b.circle',
);
const GamepadKey xButton = GamepadButtonKey(
  linuxKeyName: '???',
  macosKeyName: 'x.circle',
);
const GamepadKey startButton = GamepadButtonKey(
  linuxKeyName: '7',
  macosKeyName: 'line.horizontal.3.circle',
);
const GamepadKey selectButton = GamepadButtonKey(
  linuxKeyName: '6',
  macosKeyName: '???',
);

const GamepadKey r1Bumper = GamepadBumperKey(key: '5');
