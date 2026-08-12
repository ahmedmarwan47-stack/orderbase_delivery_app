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
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, 4.szW],
          Text(
            label,
            style: const TextStyle().setColor(foreground).s12.bold,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}
