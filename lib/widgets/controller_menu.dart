import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightrunners/ui/palette.dart';
import 'package:lightrunners/utils/gamepad_navigator.dart';

typedef ControllerMenuOprion = ({String name, VoidCallback onPressed});

final _paint = Paint()
  ..color = GamePalette.yellow
  ..strokeWidth = 10
  ..strokeCap = StrokeCap.round;

class ControllerMenu extends StatefulWidget {
  const ControllerMenu({
    required this.options,
    super.key,
  });

  final List<ControllerMenuOprion> options;

  @override
  State<ControllerMenu> createState() => _ControllerMenuState();
}

class _ControllerMenuState extends State<ControllerMenu> {
  late StreamSubscription<GamepadEvent> _gamepadSubscription;
  late GamepadNavigator _gamepadNavigator;
  int focusedOption = 0;

  @override
  void initState() {
    super.initState();
    _gamepadNavigator = GamepadNavigator(
      yAxisHandler: (int ds) => setState(() {
        focusedOption =
            (focusedOption + ds).clamp(0, widget.options.length - 1);
      }),
      onAction: () {
        widget.options[focusedOption].onPressed();
      },
    );
    _gamepadSubscription = Gamepads.events.listen(_gamepadNavigator.handle);
  }

  @override
  void dispose() {
    _gamepadSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final option in widget.options)
            TextButton(
              onPressed: option.onPressed,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    if (widget.options.indexOf(option) == focusedOption)
                      const Doritos(size: Size(12, 22))
                    else
                      const SizedBox(width: 12, height: 22),
                    const SizedBox(width: 16),
                    Text(
                      option.name,
                      style: TextStyle(
                        fontFamily: GoogleFonts.bungee().fontFamily,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Doritos extends StatelessWidget {
  const Doritos({required this.size, super.key});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _DoritosPainter(),
    );
  }
}

class _DoritosPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
