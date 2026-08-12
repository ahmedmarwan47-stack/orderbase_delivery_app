import 'package:flutter/material.dart';

import '../theme/radius.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 4)],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: foreground),
          ),
        ],
      ),
    );
  }
}
