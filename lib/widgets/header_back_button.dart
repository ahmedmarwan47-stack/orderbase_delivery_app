import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

/// Compact back affordance styled exactly like the header search / notification
/// icon tiles (rounded surface tile + hairline border) — used in screen headers
/// in place of a "‹ رجوع" text row so the header stays short and the back
/// control reads as a distinct button (not a plain inline glyph).
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, this.onTap, this.size});

  /// Defaults to popping the current route.
  final VoidCallback? onTap;

  /// Tile edge; defaults to the 40pt header icon-button size.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final double edge = size ?? AppSize.sH40;
    return Semantics(
      button: true,
      label: LocaleKeys.back.tr(),
      child: Container(
        width: edge,
        height: edge,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r12),
          border: Border.all(color: AppColors.iconButtonBorder),
        ),
        child: Center(
          child: IconWidget(
            icon: AppAssets.svg.chevronRight,
            color: AppColors.textPrimary,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
        ),
      ).onClick(onTap: onTap ?? () => Navigator.of(context).maybePop()),
    );
  }
}
