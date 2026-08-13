part of '../imports/home_imports.dart';

/// Square icon tile — used for the header search and the hero call/chat
/// actions. Purely visual; callers add a tap via `.onClick` when the affordance
/// is live (the header search opens the Queue search; the hero actions stay
/// decorative per the mockup).
class _HomeSquareIconButton extends StatelessWidget {
  const _HomeSquareIconButton({
    required this.icon,
    required this.iconColor,
    required this.size,
    required this.iconSize,
    required this.background,
    this.border,
    this.borderWidth = 1,
    this.radius,
  });

  final String icon;
  final Color iconColor;
  final double size;
  final double iconSize;
  final Color background;
  final Color? border;
  final double borderWidth;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius ?? AppCircular.r12),
        border: border != null
            ? Border.all(color: border!, width: borderWidth)
            : null,
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: iconColor,
          height: iconSize,
          width: iconSize,
        ),
      ),
    );
  }
}
