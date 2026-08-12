import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

/// Shows a bottom sheet matching the mockups' overlay pattern: a dimmed scrim,
/// a white panel pinned to the bottom with a 26px rounded top, capped at 90%
/// height and scrollable. RTL, like every screen.
Future<T?> showAppSheet<T>(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.scrim,
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      return Padding(
        // Lift the sheet above the on-screen keyboard when a field is focused.
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: media.size.height * 0.9),
            child: child,
          ),
        ),
      );
    },
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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppCircular.r26)),
      ),
      // Add the device's bottom inset (home indicator) so the sheet's last
      // control never sits under it. showModalBottomSheet doesn't do this for us.
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        top: AppPadding.pH8,
        right: AppPadding.pW20,
        bottom: AppPadding.pH24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 42.w, // drag grabber pill — no token
              height: 5.h,
              margin: EdgeInsets.symmetric(vertical: AppMargin.mH8),
              decoration: BoxDecoration(
                color: AppColors.sheetGrabber,
                borderRadius: BorderRadius.circular(AppCircular.r3),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (onBack != null) ...[
                    _SheetIconButton(
                      icon: AppAssets.svg.chevronRight,
                      label: LocaleKeys.a11yBack.tr(),
                      onTap: onBack!,
                    ),
                    8.szW,
                  ],
                  Text(title, style: const TextStyle().setMainTextColor.s18.extraBold),
                ],
              ),
              _SheetIconButton(
                icon: AppAssets.svg.x,
                label: LocaleKeys.a11yClose.tr(),
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              child: body.paddingOnly(top: AppPadding.pH16),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({required this.icon, required this.onTap, this.label});
  final String icon;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Visual tile stays 34 (per the mockup); the tap area is padded out to a
    // 44pt minimum so it's reliably hittable one-handed.
    return Semantics(
      button: true,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Center(
          child: Container(
            width: 34.w, // icon button tile — no token
            height: 34.h,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppCircular.r10),
            ),
            child: Center(
              child: IconWidget(
                icon: icon,
                color: AppColors.textTertiary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
            ),
          ),
        ),
      ).onClick(onTap: onTap),
    );
  }
}
