import 'dart:ui';

class GamePalette {
  static const red = Color(0xFFE03232);
  static const orange = Color(0xFFE07B32);
  static const yellow = Color(0xFFE0D932);
  static const green = Color(0xFF89E032);
  static const lightBlue = Color(0xFF32D6E0);
  static const blue = Color(0xFF3263E0);
  static const pink = Color(0xFFE032CF);
  static const silver = Color(0xFFCFCFCF);
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);

  static const shipValues = [
    lightBlue,
    pink,
    silver,
    red,
    orange,
    yellow,
    green,
    blue,
  ];

  static final bulletPaints = shipValues.map((color) {
    return Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
  }).toList(growable: false);
}
