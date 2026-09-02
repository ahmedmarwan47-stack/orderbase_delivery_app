part of '../imports/home_imports.dart';

/// The hero's "explain this" mechanism: a small control sitting inline with a
/// line of text, and an ink tooltip that **floats above it** when tapped.
///
/// It floats rather than expanding the card. An earlier version pushed the
/// card open like a disclosure, which moved everything under it; a tooltip is
/// meant to hover and go away. It opens *upward* (`preferBelow: false`) so it
/// never lands on the destination — the one thing the courier opened the card
/// to read — and Flutter flips or clamps it when there is no room.
///
/// Two hints use it: the ⓘ on the trip line (what the return time and the
/// kilometres actually mean) and the note badge on the meta row (the customer
/// left a note; open the order to read it).

/// Wraps any control in a manually-triggered tooltip.
///
/// Manual, not `TooltipTriggerMode.tap`: the whole hero card is tappable, so
/// the trigger needs its own recognizer to win the gesture instead of opening
/// the order underneath.
class _HintAnchor extends StatefulWidget {
  const _HintAnchor({
    required this.message,
    required this.label,
    required this.child,
  });

  final String message;

  /// Screen-reader name for the hint this opens.
  final String label;

  final Widget child;

  @override
  State<_HintAnchor> createState() => _HintAnchorState();
}

class _HintAnchorState extends State<_HintAnchor> {
  final GlobalKey<TooltipState> _tip = GlobalKey<TooltipState>();

  void _show() {
    AppHaptics.tick();
    _tip.currentState?.ensureTooltipVisible();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: _tip,
      message: widget.message,
      triggerMode: TooltipTriggerMode.manual,
      // Above the control, clear of the address below it.
      preferBelow: false,
      verticalOffset: AppSize.sH20,
      showDuration: const Duration(seconds: 8),
      textAlign: TextAlign.right,
      margin: EdgeInsets.symmetric(horizontal: AppPadding.pW20),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH12,
      ),
      decoration: BoxDecoration(
        color: AppColors.inkFill,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        boxShadow: AppShadows.card,
      ),
      textStyle: const TextStyle().setWhite.s12.regular.withHeight(1.6),
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: _show,
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
      ),
    );
  }
}

/// The ⓘ beside the trip line — a small ink ring, matching the black the line
/// beside it is set in.
class _HintDot extends StatelessWidget {
  const _HintDot({required this.message, required this.label});

  final String message;
  final String label;

  @override
  Widget build(BuildContext context) {
    return _HintAnchor(
      message: message,
      label: label,
      // The ring is 16pt; the hit area is padded out to 28 so it stays
      // reliably tappable beside a line of 12px text.
      child: SizedBox(
        width: AppSize.sH28,
        height: AppSize.sH28,
        child: Center(
          child: Container(
            width: AppSize.sH16,
            height: AppSize.sH16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.textPrimary),
            ),
            child: Center(
              child: Text(
                'i',
                style: const TextStyle()
                    .setMainTextColor
                    .s10
                    .bold
                    .withHeight(1)
                    .copyWith(fontFamily: 'sans-serif'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The customer-note badge on the meta row.
///
/// Built as a **pill, not a dot**, so it stands beside the cash pill as its
/// twin: same corner, same padding, and — stretched by the row's
/// [IntrinsicHeight] — exactly the same height. A circle next to a pill read
/// as two unrelated things sharing a row.
///
/// The hero cannot show a note in full: it is a paragraph. The badge says one
/// exists and sends the courier to the order detail to read it, which beats
/// truncating someone's instructions.
class _NotePill extends StatelessWidget {
  const _NotePill();

  @override
  Widget build(BuildContext context) {
    return _HintAnchor(
      message: LocaleKeys.homeNoteHint.tr(),
      label: LocaleKeys.homeNoteHintLabel.tr(),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.heroCodPillBg,
          borderRadius: BorderRadius.circular(AppCircular.r8),
        ),
        padding: EdgeInsets.symmetric(horizontal: AppPadding.pW8),
        child: Center(
          child: IconWidget(
            icon: AppAssets.svg.note,
            color: AppColors.postponedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
        ),
      ),
    );
  }
}
