import 'package:flutter/widgets.dart';
import 'package:phased/phased.dart';

class OpacityBlinker extends StatelessWidget {
  const OpacityBlinker({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _OpacityBlinkerPhased(state: _State(), child: child);
  }
}

class _State extends PhasedState<bool> {
  _State()
      : super(
          values: [true, false],
          initialValue: true,
          ticker: const Duration(milliseconds: 600),
        );
}

class _OpacityBlinkerPhased extends Phased<bool> {
  const _OpacityBlinkerPhased({
    required super.state,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: state.value ? 1 : 0.4,
      child: child,
    );
  }
}
