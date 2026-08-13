import 'package:flutter/material.dart';

import '../utils/app_motion.dart';

/// Tap handling via extension — `widget.onClick(onTap: fn)` instead of a bare
/// `GestureDetector`. Pass `ripple: true` (with a `borderRadius`) for an
/// `InkWell` material ripple instead of an opaque gesture.
extension OnClick on Widget {
  Widget onClick({
    required VoidCallback? onTap,
    bool ripple = false,
    BorderRadius? borderRadius,
  }) {
    if (ripple) {
      return _PressScale(
        child: InkWell(onTap: onTap, borderRadius: borderRadius, child: this),
      );
    }
    return _PressScale(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: this,
      ),
    );
  }
}

/// A subtle tactile press: the child dips to 0.98 on tap-down and springs back
/// to 1.0 on release/cancel over [AppMotion.tick]. Fires app-wide on every
/// tappable, so it stays fast and never bounces. Reduce Motion renders the
/// child untouched (no scale wrapper's animation), and the gesture layer here
/// is passive — it never swallows taps or alters the wrapped hit-testing.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});

  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return widget.child;

    return Listener(
      onPointerDown: (_) {
        if (!_pressed) setState(() => _pressed = true);
      },
      onPointerUp: (_) {
        if (_pressed) setState(() => _pressed = false);
      },
      onPointerCancel: (_) {
        if (_pressed) setState(() => _pressed = false);
      },
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: AppMotion.tick,
        curve: AppMotion.ease,
        child: widget.child,
      ),
    );
  }
}
