part of '../imports/home_imports.dart';

/// The hero's shared "explain this" mechanism: a small round trigger sitting
/// inline with a line of text, and an ink note that **expands in place** under
/// it when tapped.
///
/// It expands rather than floating because a popover landed on top of the
/// address — the one thing the courier opened the card to read. Pushing the
/// card open instead costs a few pixels and covers nothing.
///
/// Two hints use it today: the ⓘ on the trip line (what the return time and
/// the kilometres actually mean) and the note badge on the meta row (the
/// customer left a note; open the order to read it).

/// The round trigger. Quiet ring while closed, filled while its note is open,
/// so the control shows which state it is in.
class _HintDot extends StatelessWidget {
  const _HintDot({
    required this.open,
    required this.onTap,
    required this.label,
    this.icon,
    this.tint = AppColors.inkFill,
    this.idleBorder = AppColors.borderDefault,
    this.idleForeground = AppColors.textTertiary,
  });

  final bool open;
  final VoidCallback onTap;

  /// Screen-reader name for the hint this opens.
  final String label;

  /// Glyph inside the ring; null draws a typographic "i".
  final String? icon;

  /// Fill (and border) once open.
  final Color tint;
  final Color idleBorder;
  final Color idleForeground;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final fg = open ? AppColors.surface : idleForeground;
    return Semantics(
      button: true,
      expanded: open,
      label: label,
      // An explicit recognizer: the whole hero card is tappable, and this has
      // to win the gesture rather than opening the order underneath.
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // The ring is 18pt; the hit area is padded out to 28 so it stays
        // reliably tappable beside a line of 12px text.
        child: SizedBox(
          width: AppSize.sH28,
          height: AppSize.sH28,
          child: Center(
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : AppMotion.stamp,
              curve: AppMotion.ease,
              width: AppSize.sH18,
              height: AppSize.sH18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: open ? tint : Colors.transparent,
                border: Border.all(color: open ? tint : idleBorder),
              ),
              child: Center(
                child: icon == null
                    ? Text(
                        'i',
                        style: const TextStyle()
                            .setColor(fg)
                            .s10
                            .bold
                            .withHeight(1)
                            .copyWith(fontFamily: 'sans-serif'),
                      )
                    : IconWidget(
                        icon: icon!,
                        color: fg,
                        height: AppSize.sH10,
                        width: AppSize.sW10,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The note itself: ink, full width, growing out from under its trigger.
///
/// One value drives the whole arrival — the height unfurls, the body fades in
/// and settles down the last few pixels, and the caret comes with it — so it
/// reads as a single movement rather than three effects. Under Reduce Motion
/// it is simply there or not.
class _InlineHintNote extends StatelessWidget {
  const _InlineHintNote({
    required this.open,
    required this.message,
    required this.onTap,
  });

  final bool open;
  final String message;

  /// Tapping the note dismisses it (and never opens the order beneath).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: open ? 1 : 0),
      duration: reduced ? Duration.zero : AppMotion.settle,
      curve: AppMotion.ease,
      builder: (context, t, child) {
        if (t == 0) return const SizedBox.shrink();
        return ClipRect(
          child: Align(
            alignment: AlignmentDirectional.topCenter,
            heightFactor: t,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, -6.h * (1 - t)),
                child: child,
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            6.szH,
            // The caret ties the note back to the trigger it came from.
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 8.w),
                child: CustomPaint(
                  size: Size(12.w, 6.h),
                  painter: const _CaretPainter(color: AppColors.inkFill),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.inkFill,
                borderRadius: BorderRadius.circular(AppCircular.r12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW12,
                vertical: AppPadding.pH12,
              ),
              child: Text(
                message,
                style: const TextStyle().setWhite.s12.regular.withHeight(1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small upward triangle — the note's pointer back at its trigger.
class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaretPainter old) => old.color != color;
}

/// Holds one inline hint open, and closes it again on its own after a while —
/// it is an aside, and a courier who tapped it once should not have to tap it
/// again to get their card back.
mixin _InlineHintHost<T extends StatefulWidget> on State<T> {
  bool hintOpen = false;
  Timer? _autoClose;
  static const Duration _linger = Duration(seconds: 8);

  void toggleHint() {
    AppHaptics.tick();
    setState(() => hintOpen = !hintOpen);
    _autoClose?.cancel();
    if (hintOpen) {
      _autoClose = Timer(_linger, () {
        if (mounted) setState(() => hintOpen = false);
      });
    }
  }

  @override
  void dispose() {
    _autoClose?.cancel();
    super.dispose();
  }
}
