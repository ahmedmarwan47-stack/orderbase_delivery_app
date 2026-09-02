part of '../imports/auth_imports.dart';

/// The ink-black primary action shared across the Auth flow: full-width, 56px
/// tall, 16px radius, an optional leading glyph, a centered bold label. Disabled
/// drops to the border-default fill with a muted label (matching the COD confirm
/// button), naming *why* it's inert where the caller supplies a disabled label.
class _AuthPrimaryButton extends StatelessWidget {
  const _AuthPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.icon,
    this.iconColor,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  /// Optional leading glyph (AppAssets path).
  final String? icon;

  /// Overrides the glyph tint (e.g. cash-bright green on the WhatsApp send).
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final Color fg = enabled ? AppColors.surface : AppColors.chipCountMuted;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        height: AppSize.sH56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.inkFill : AppColors.borderDefault,
          borderRadius: BorderRadius.circular(AppCircular.r16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              IconWidget(
                icon: icon!,
                color: iconColor ?? fg,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
            ],
            Text(label, style: const TextStyle().setColor(fg).s14.semiBold),
          ],
        ),
      ).onClick(onTap: enabled ? onTap : null),
    );
  }
}

/// The outlined secondary action (Auth.dc.html 1f "الرجوع للطلبات"): white
/// surface, 1px hairline border, 48px tall, ink label.
class _AuthOutlinedButton extends StatelessWidget {
  const _AuthOutlinedButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: AppSize.sH48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r16),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Text(
          label,
          style: const TextStyle().setMainTextColor.s14.semiBold,
        ),
      ).onClick(onTap: onTap),
    );
  }
}
