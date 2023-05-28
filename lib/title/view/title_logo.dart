import 'package:flutter/material.dart';
import 'package:phased/phased.dart';

class LogoController extends PhasedState<int> {
  LogoController() : super(values: [0, 1, 2], autostart: true);
}

class TitleLogo extends Phased<int> {
  const TitleLogo({
    required super.state,
    super.key,
  });

  static const _width = 500.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutSine,
            onEnd: state.next,
            width: state.phaseValue(
              values: {
                0: 0,
                1: _width,
                2: _width,
              },
              defaultValue: 0,
            ),
            child: Image.asset('assets/images/logo_background.png'),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutSine,
            width: state.phaseValue(
              values: {
                0: 0,
                1: 0,
                2: _width,
              },
              defaultValue: 0,
            ),
            child: Image.asset('assets/images/logo_writting.png'),
          ),
        ],
      ),
    );
  }
}
