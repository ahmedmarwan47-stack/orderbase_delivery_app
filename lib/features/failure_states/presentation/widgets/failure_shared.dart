part of '../imports/failure_states_imports.dart';

/// Centralised icon lookup for the failure flow. Maps the mockup's glyph ids to
/// [AppAssets] paths.
abstract final class FailureIcons {
  static String get tick => AppAssets.svg.tick; // i-tick (bare check)
  static String get alert => AppAssets.svg.alert; // i-alert (!-in-circle)
  static String get box => AppAssets.svg.box; // i-box (package)
  static String get whatsapp => AppAssets.svg.wa; // i-wa (whatsapp)

  // Exact matches.
  static String get back => AppAssets.svg.chevronRight; // i-cr (RTL back)
  static String get chevronLeft => AppAssets.svg.chevronLeft; // i-cl
  static String get clock => AppAssets.svg.clock;
  static String get undo => AppAssets.svg.undo;
  static String get phone => AppAssets.svg.phone;
  static String get pin => AppAssets.svg.pin;
  static String get cam => AppAssets.svg.cam;
  static String get nav => AppAssets.svg.nav;
  static String get home => AppAssets.svg.home;
  static String get orders => AppAssets.svg.orders;
  static String get note => AppAssets.svg.note;
  static String get wallet => AppAssets.svg.wallet;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet chrome
// ─────────────────────────────────────────────────────────────────────────────

/// The white bottom-sheet panel used by 1a–1f: rounded top, grabber handle, an
/// optional header row (back / title / close) and step caption, then a
/// scrollable [body]. Designed to be a `showAppSheet` child.
class _SheetScaffold extends StatelessWidget {
  const _SheetScaffold({
    required this.body,
    this.title,
    this.stepCaption,
    this.onBack,
  });

  final Widget body;
  final String? title;
  final String? stepCaption;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppCircular.r26),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH24 + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Grabber(),
          if (title != null) ...[
            8.szH,
            Row(
              children: [
                if (onBack != null) ...[
                  _SheetIconTile(icon: FailureIcons.back, onTap: onBack!),
                  8.szW,
                ],
                Flexible(
                  child: Text(
                    title!,
                    style: const TextStyle().setMainTextColor.s18.bold,
                  ),
                ),
              ],
            ),
          ],
          if (stepCaption != null) ...[
            4.szH,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                stepCaption!,
                style: const TextStyle()
                    .setColor(AppColors.chipCountMuted)
                    .s12
                    .semiBold,
              ),
            ),
          ],
          16.szH,
          Flexible(child: SingleChildScrollView(child: body)),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42.w,
        height: 5.h,
        margin: EdgeInsets.symmetric(vertical: AppMargin.mH8),
        decoration: BoxDecoration(
          color: AppColors.sheetGrabber,
          borderRadius: BorderRadius.circular(AppCircular.r3),
        ),
      ),
    );
  }
}

/// The 34×34 muted icon tile used for sheet back / close buttons. Tap area is
/// padded to a 44pt minimum for one-handed use.
class _SheetIconTile extends StatelessWidget {
  const _SheetIconTile({required this.icon, required this.onTap});
  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Center(
          child: Container(
            width: 34.w,
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

// ─────────────────────────────────────────────────────────────────────────────
// Buttons
// ─────────────────────────────────────────────────────────────────────────────

/// Full-width 56px primary action. Ink-black by default; [danger] fills with
/// the destructive red used to log the failure (1e).
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
    this.danger = false,
  });

  final String label;
  final VoidCallback onTap;
  final String? leadingIcon;
  final String? trailingIcon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: AppSize.sH56,
        decoration: BoxDecoration(
          color: danger ? AppColors.dangerAccent : AppColors.inkFill,
          borderRadius: BorderRadius.circular(AppCircular.r15),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              IconWidget(
                icon: leadingIcon!,
                color: AppColors.surface,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle().setWhite.s14.semiBold,
              ),
            ),
            if (trailingIcon != null) ...[
              8.szW,
              IconWidget(
                icon: trailingIcon!,
                color: AppColors.surface,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
            ],
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

/// White outlined secondary button (1a postpone, 1e back-to-reason, 1f back).
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({
    required this.label,
    required this.onTap,
    this.leadingIcon,
    this.leadingIconColor,
    this.labelColor,
    this.borderColor,
    this.borderWidth = 1,
  });

  final String label;
  final VoidCallback onTap;
  final String? leadingIcon;
  final Color? leadingIconColor;
  final Color? labelColor;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: AppSize.sH48,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r15),
          border: Border.all(
            color: borderColor ?? AppColors.borderDefault,
            width: borderWidth,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              IconWidget(
                icon: leadingIcon!,
                color: leadingIconColor ?? AppColors.textPrimary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle()
                    .setColor(labelColor ?? AppColors.textPrimary)
                    .s14
                    .semiBold,
              ),
            ),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fields, tags, callouts
// ─────────────────────────────────────────────────────────────────────────────

/// A caption label above a field/section ("ملاحظة (إلزامية)", …).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.strong = false});
  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: strong
            ? const TextStyle().setMainTextColor.s14.semiBold
            : const TextStyle().setSecondaryColor.s12.semiBold,
      ),
    );
  }
}

/// The mandatory-note field (1b/1c/1d). Editable, prefilled with the mockup's
/// sample text; brand-red cursor per the design.
class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, this.hint});
  final TextEditingController controller;

  /// Optional placeholder shown when the field is empty (used by the optional
  /// «سبب آخر» details field).
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: AppSize.sH56),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderHeader),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH12,
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        cursorColor: AppColors.brand,
        style: const TextStyle().setMainTextColor.s14.regular.withHeight(1.5),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: hint,
          hintStyle: const TextStyle().setHintColor.s14.regular.withHeight(1.5),
        ),
      ),
    );
  }
}

/// The small "يرجع للفرع" / "قابل للإعادة" tag on a reason row.
class _ReasonTag extends StatelessWidget {
  const _ReasonTag({required this.outcome, this.onLightRow = false});
  final ReasonOutcome outcome;

  /// The selected row already has a red wash, so its tag sits on white.
  final bool onLightRow;

  @override
  Widget build(BuildContext context) {
    if (outcome == ReasonOutcome.none) return const SizedBox.shrink();
    final returns = outcome == ReasonOutcome.returnsToBranch;
    final bg = returns
        ? (onLightRow ? AppColors.surface : AppColors.failedBg)
        : AppColors.deliveredBg;
    final fg = returns ? AppColors.failedText : AppColors.deliveredText;
    final label = returns
        ? LocaleKeys.failureTagReturnsToBranch.tr()
        : LocaleKeys.failureTagRetryable.tr();
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH4,
      ),
      child: Text(label, style: const TextStyle().setColor(fg).s12.semiBold),
    );
  }
}

/// A 22×22 radio dot. Selected = filled brand with a white tick; unselected =
/// a 2px ring.
class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sW22,
      height: AppSize.sH22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.brand : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.brand : AppColors.reasonDotBorder,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: IconWidget(
                icon: FailureIcons.tick,
                color: AppColors.surface,
                height: AppSize.sH12,
                width: AppSize.sW12,
              ),
            )
          : null,
    );
  }
}

/// A tinted callout row with a leading icon and body text (amber / red / grey).
class _Callout extends StatelessWidget {
  const _Callout({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.bg,
    required this.textColor,
    this.borderColor,
  });

  final String icon;
  final Color iconColor;
  final String text;
  final Color bg;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW16,
        vertical: AppPadding.pH12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: icon,
            color: iconColor,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Expanded(
            child: Text(
              text,
              style: const TextStyle()
                  .setColor(textColor)
                  .s12
                  .regular
                  .withHeight(1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order-detail context (behind the sheets)
// ─────────────────────────────────────────────────────────────────────────────

/// The dimmed order-detail screen the failure sheets sit over: a white header
/// (back tile · order number · customer/area · optional status badge) on the
/// paper ground. The OS status bar is the only one shown (no fake 9:41).
class _OrderContextBackground extends StatelessWidget {
  const _OrderContextBackground({
    required this.ctx,
    this.statusBadge,
    this.body,
  });
  final FailureContext ctx;
  final Widget? statusBadge;
  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: AppColors.surface,
          padding: EdgeInsets.only(
            left: AppPadding.pW20,
            right: AppPadding.pW20,
            top: AppPadding.pH8,
            bottom: AppPadding.pH16,
          ),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
            ),
            child: Row(
              children: [
                Container(
                  width: AppSize.sW44,
                  height: AppSize.sH44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppCircular.r12),
                  ),
                  child: Center(
                    child: IconWidget(
                      icon: FailureIcons.back,
                      color: AppColors.textTertiary,
                      height: AppSize.sH18,
                      width: AppSize.sW18,
                    ),
                  ),
                ),
                12.szW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctx.orderNum,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle().setMainTextColor.s16.bold,
                      ),
                      4.szH,
                      Text(
                        ctx.customerAndArea,
                        style: const TextStyle().setSecondaryColor.s12.regular,
                      ),
                    ],
                  ),
                ),
                if (statusBadge != null) ...[12.szW, statusBadge!],
              ],
            ).paddingOnly(bottom: AppPadding.pH16),
          ),
        ),
        Expanded(
          child: Container(
            color: AppColors.background,
            width: double.infinity,
            child: body,
          ),
        ),
      ],
    );
  }
}

/// A small status pill (e.g. "في الطريق", "تعذّر التسليم").
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH4,
      ),
      child: Text(label, style: const TextStyle().setColor(fg).s12.semiBold),
    );
  }
}
