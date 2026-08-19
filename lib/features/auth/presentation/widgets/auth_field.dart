part of '../imports/auth_imports.dart';

/// Auth glyph sentinels → real AppAssets paths. The store / lock / eye / eye-off
/// icons were extracted from Auth.dc.html into the icon set.
const String _kStoreIcon = 'store'; // sentinel, resolved in [_authGlyph]
const String _kLockIcon = 'lock';
const String _kEyeIcon = 'eye';

/// Resolves an Auth glyph sentinel to its real AppAssets path.
String _authGlyph(String name) => switch (name) {
  _kStoreIcon => AppAssets.svg.store,
  _kLockIcon => AppAssets.svg.lock,
  _kEyeIcon => AppAssets.svg.eye,
  _ => name,
};

/// The signature Orderbase input (DESIGN.md): a labeled field on a muted surface
/// (#F4F3F0), 14px radius, 52px tall, a leading stroke glyph, and a **2px ink
/// border** with a brand-red cursor when active. Supports a password obscure +
/// eye toggle, an optional trailing widget (e.g. a green match check), and an
/// optional label-trailing link ("نسيتها؟"). Owns only its own focus/obscure
/// visuals via ListenableBuilder — no `setState`.
class _AuthField extends StatefulWidget {
  const _AuthField({
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.obscure = false,
    this.showToggle = false,
    this.keyboardType,
    this.inputFormatters,
    this.ltr = false,
    this.tabular = false,
    this.trailing,
    this.labelTrailing,
    this.compact = false,
  });

  final String label;
  final TextEditingController controller;

  /// Leading glyph — an AppAssets path, or one of the `_k*Icon` sentinels.
  final String icon;
  final String? hint;

  /// Password field (dots). With [showToggle] the eye reveals/hides.
  final bool obscure;
  final bool showToggle;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool ltr;
  final bool tabular;

  /// End-of-field widget (used instead of the eye toggle), e.g. a match check.
  final Widget? trailing;

  /// Widget aligned to the label row's end, e.g. a "نسيتها؟" link.
  final Widget? labelTrailing;

  /// Tighter type scale (label 12 / input 14 instead of 14 / 16) for the
  /// carded login form; leaves the field height untouched.
  final bool compact;

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  final FocusNode _focus = FocusNode();
  late final ValueNotifier<bool> _obscured = ValueNotifier(widget.obscure);

  @override
  void dispose() {
    _focus.dispose();
    _obscured.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: widget.compact
                  ? const TextStyle().setTertiaryColor.s12.semiBold
                  : const TextStyle().setTertiaryColor.s14.semiBold,
            ),
            if (widget.labelTrailing != null) ...[
              const Spacer(),
              widget.labelTrailing!,
            ],
          ],
        ),
        8.szH,
        ListenableBuilder(
          listenable: Listenable.merge([_focus, _obscured]),
          builder: (context, _) {
            final active = _focus.hasFocus;
            final obscureText = widget.showToggle
                ? _obscured.value
                : widget.obscure;
            var textStyle = widget.compact
                ? const TextStyle().setMainTextColor.s14.semiBold
                : const TextStyle().setMainTextColor.s16.semiBold;
            if (widget.tabular) textStyle = textStyle.tabular;
            if (obscureText) textStyle = textStyle.copyWith(letterSpacing: 4);

            return Container(
              height: AppSize.sH52,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppCircular.r14),
                border: Border.all(
                  color: active ? AppColors.inkFill : AppColors.borderDefault,
                  width: active ? 2 : 1,
                ),
              ),
              padding: EdgeInsetsDirectional.only(
                start: AppPadding.pW12,
                end: AppPadding.pW12,
              ),
              child: Row(
                children: [
                  IconWidget(
                    icon: _authGlyph(widget.icon),
                    color: active
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    height: AppSize.sH20,
                    width: AppSize.sW20,
                  ),
                  12.szW,
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focus,
                      obscureText: obscureText,
                      obscuringCharacter: '•',
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      textDirection: widget.ltr ? TextDirection.ltr : null,
                      cursorColor: AppColors.brand,
                      style: textStyle,
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: widget.compact
                            ? const TextStyle()
                                  .setColor(AppColors.chipCountMuted)
                                  .s14
                                  .regular
                            : const TextStyle()
                                  .setColor(AppColors.chipCountMuted)
                                  .s16
                                  .regular,
                      ),
                    ),
                  ),
                  if (widget.showToggle) ...[
                    8.szW,
                    _EyeToggle(
                      obscured: _obscured.value,
                      onTap: () => _obscured.value = !_obscured.value,
                    ),
                  ] else if (widget.trailing != null) ...[
                    8.szW,
                    widget.trailing!,
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The show/hide-password button — eye when hidden (tap to reveal), eye-off
/// when shown (tap to hide).
class _EyeToggle extends StatelessWidget {
  const _EyeToggle({required this.obscured, required this.onTap});
  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: obscured
          ? LocaleKeys.authShowPassword.tr()
          : LocaleKeys.authHidePassword.tr(),
      child: IconWidget(
        icon: obscured ? AppAssets.svg.eye : AppAssets.svg.eyeOff,
        color: AppColors.textSecondary,
        height: AppSize.sH20,
        width: AppSize.sW20,
      ).onClick(onTap: onTap),
    );
  }
}

/// A small danger-red text link ("نسيت كلمة المرور؟" / "نسيتها؟"). [compact]
/// drops it to 12px for the tighter carded login form.
class _AuthLink extends StatelessWidget {
  const _AuthLink({
    required this.label,
    required this.onTap,
    this.compact = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final base = const TextStyle().setColor(AppColors.dangerAccent).semiBold;
    return Text(
      label,
      style: compact ? base.s12 : base.s14,
    ).onClick(onTap: onTap);
  }
}
