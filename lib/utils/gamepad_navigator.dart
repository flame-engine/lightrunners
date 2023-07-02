import 'package:gamepads/gamepads.dart';
import 'package:lightrunners/utils/gamepad_map.dart';

class GamepadNavigator {
  final Function(int)? xAxisHandler;
  final Function(int)? yAxisHandler;
  final Function()? onAction;
  final Function()? onAny;

  GamepadNavigator({
    this.xAxisHandler,
    this.yAxisHandler,
    this.onAction,
    this.onAny,
  });

  int _getValue(GamepadEvent event) {
    return GamepadAnalogAxis.normalizedIntensity(event).sign.toInt();
  }

  void handle(GamepadEvent event) {
    if (event.value == 1.0) {
      onAny?.call();
    }

    if (leftXAxis.matches(event)) {
      final value = _getValue(event);
      if (value != 0) {
        xAxisHandler?.call(value);
      }
    } else if (leftYAxis.matches(event)) {
      final value = _getValue(event);
      if (value != 0) {
        yAxisHandler?.call(value);
      }
    } else if (aButton.matches(event)) {
      onAction?.call();
    }
  }
}
