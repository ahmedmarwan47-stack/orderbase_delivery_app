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
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
      ),
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        top: AppPadding.pH8,
        right: AppPadding.pW20,
        bottom: AppPadding.pH24,
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
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (onBack != null) ...[
                    _SheetIconButton(icon: AppAssets.svg.chevronRight, onTap: onBack!),
                    8.szW,
                  ],
                  Text(title, style: const TextStyle().setMainTextColor.s18.extraBold),
                ],
              ),
              _SheetIconButton(
                icon: AppAssets.svg.x,
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
  const _SheetIconButton({required this.icon, required this.onTap});
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34.w, // icon button tile — no token
      height: 34.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: AppColors.textTertiary,
          height: AppSize.sH18,
          width: AppSize.sW18,
        ),
      ),
    ).onClick(onTap: onTap);
  }
}
