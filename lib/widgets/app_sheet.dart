import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Shows a bottom sheet matching the mockups' overlay pattern: a dimmed scrim,
/// a white panel pinned to the bottom with a 26px rounded top, capped at 90%
/// height and scrollable. RTL, like every screen.
Future<T?> showAppSheet<T>(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: child,
      ),
    ),
  );
}

/// The white sheet panel: grabber handle, a header row (optional back button,
/// title, close button), then [body]. The body scrolls if it overflows.
class SheetShell extends StatelessWidget {
  const SheetShell({super.key, required this.title, required this.body, this.onBack});

  final String title;
  final Widget body;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
              decoration: BoxDecoration(
                color: AppColors.sheetGrabber,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (onBack != null) ...[
                    _SheetIconButton(icon: AppIconName.chevronRight, onTap: onBack!),
                    const SizedBox(width: AppSpacing.s8),
                  ],
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              _SheetIconButton(
                icon: AppIconName.x,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.s16),
                child: body,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({required this.icon, required this.onTap});
  final AppIconName icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: AppIcon(icon, color: AppColors.textTertiary, size: 18)),
      ),
    );
  }
}
