abstract class GamepadKey {
  const GamepadKey();

  bool matches(String key);
}

class GamepadLeftXAxis implements GamepadKey {
  const GamepadLeftXAxis();

  @override
  bool matches(String key) {
    return key == '0' || key == 'l.joystick - xAxis';
  }
}

class GamepadLeftYAxis implements GamepadKey {
  const GamepadLeftYAxis();

  @override
  bool matches(String key) {
    return key == '1' || key == 'l.joystick - yAxis';
  }
}

class GamepadRightXAxis implements GamepadKey {
  const GamepadRightXAxis();

  @override
  bool matches(String key) {
    return key == '3' || key == 'r.joystick - xAxis';
  }
}

class GamepadRightYAxis implements GamepadKey {
  const GamepadRightYAxis();

  @override
  bool matches(String key) {
    return key == '4' || key == 'r.joystick - yAxis';
  }
}
