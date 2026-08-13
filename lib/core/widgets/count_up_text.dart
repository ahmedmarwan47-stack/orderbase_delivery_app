import 'package:flutter/widgets.dart';

import '../utils/app_motion.dart';

/// Counts an integer up to [value] once on build, formatting each frame through
/// [format]. Used for the cash "settle" — the collected figure lands with
/// weight instead of just appearing. Under Reduce Motion (or [animate] false)
/// it renders the final value immediately. Keep [style] tabular so the digits
/// don't jitter width as they climb.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.textDirection = TextDirection.ltr,
    this.duration = AppMotion.focal,
    this.animate = true,
  });

  final int value;
  final String Function(int) format;
  final TextStyle? style;
  final TextDirection textDirection;
  final Duration duration;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (!animate || AppMotion.reduced(context) || value <= 0) {
      return Text(format(value), textDirection: textDirection, style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.ease,
      builder: (_, t, _) => Text(
        format((value * t).round()),
        textDirection: textDirection,
        style: style,
      ),
    );
  }
}
