import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color? border;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    // When an order changes state (transit → delivered) the colours tween and
    // the label cross-fades instead of hard-swapping. Shape / padding / size
    // stay identical. Reduce Motion collapses every duration to zero for an
    // instant swap.
    final Duration duration =
        AppMotion.reduced(context) ? Duration.zero : AppMotion.fill;

    return AnimatedContainer(
      duration: duration,
      curve: AppMotion.ease,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, 4.szW],
          AnimatedSwitcher(
            duration: duration,
            switchInCurve: AppMotion.ease,
            switchOutCurve: AppMotion.ease,
            child: TweenAnimationBuilder<Color?>(
              key: ValueKey<String>(label),
              tween: ColorTween(begin: foreground, end: foreground),
              duration: duration,
              curve: AppMotion.ease,
              builder: (context, color, child) => Text(
                label,
                style: const TextStyle().setColor(color ?? foreground).s12.bold,
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}
