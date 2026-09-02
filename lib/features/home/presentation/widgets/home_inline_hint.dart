part of '../imports/home_imports.dart';

/// The hero's "explain this" mechanism: a small control sitting inline with a
/// line of text, and an ink bubble that **grows out of it**, dwells long
/// enough to be read, and leaves on its own.
///
/// Built rather than borrowed. Flutter's `Tooltip` only auto-dismisses on its
/// own tap/long-press paths — shown manually (the only way to keep the tappable
/// hero card from stealing the gesture) it stays up until something else is
/// touched, and its fade has no relationship to the control that opened it.
///
/// The motion says one thing: *this belongs to that icon*. The bubble scales up
/// from the exact point the courier pressed, with its caret as the origin, and
/// the dismissal reverses that entrance faster than it arrived. Nothing else on
/// Home moves — an aside on a card read between stops has not earned a focal
/// moment, and the delivery flow has.
///
/// Two hints use it: the ⓘ on the trip line (what the return time and the
/// kilometres actually mean) and the note badge on the meta row (the customer
/// left a note; open the order to read it).

/// Wraps any control so tapping it raises [message] above the control.
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

class _HintAnchorState extends State<_HintAnchor>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();

  /// Arrives over [AppMotion.fill]; leaves over the shorter [AppMotion.stamp],
  /// because an exit that takes as long as the entrance reads as lag.
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: AppMotion.fill,
    reverseDuration: AppMotion.stamp,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _anim,
    curve: AppMotion.ease,
    reverseCurve: AppMotion.ease,
  );

  Timer? _dwell;

  /// The control's rect in global space, measured when the hint opens — what
  /// the bubble is positioned against and scaled out of.
  Rect _anchor = Rect.zero;

  /// The scrollable the control lives in, if any. A bubble pinned to a stale
  /// rect while the page moves under it looks broken, so scrolling closes it.
  ScrollPosition? _scrollPosition;

  /// Long enough to finish reading, short enough not to sit there. Scaled off
  /// the message so the shorter hint does not outstay the longer one.
  Duration get _dwellDuration => Duration(
    milliseconds: (2200 + widget.message.length * 55).clamp(4000, 9000),
  );

  @override
  void dispose() {
    _dwell?.cancel();
    _unbindScroll();
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _unbindScroll() {
    _scrollPosition?.removeListener(_hideNow);
    _scrollPosition = null;
  }

  void _show() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    AppHaptics.tick();
    _anchor = box.localToGlobal(Offset.zero) & box.size;

    _unbindScroll();
    _scrollPosition = Scrollable.maybeOf(context)?.position
      ?..addListener(_hideNow);

    _portal.show();
    if (AppMotion.reduced(context)) {
      _anim.value = 1;
    } else {
      _anim.forward(from: 0);
    }
    _dwell?.cancel();
    _dwell = Timer(_dwellDuration, _hideNow);
  }

  void _hideNow() => unawaited(_hide());

  Future<void> _hide() async {
    _dwell?.cancel();
    _dwell = null;
    _unbindScroll();
    if (!_portal.isShowing) return;
    if (!mounted || AppMotion.reduced(context)) {
      _anim.value = 0;
      _portal.hide();
      return;
    }
    await _anim.reverse();
    // A second tap can re-open it mid-exit; only tear down if it is still out.
    if (mounted && _anim.isDismissed) _portal.hide();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildBubble,
      child: Semantics(
        button: true,
        label: widget.label,
        // An explicit recognizer: the whole hero card is tappable, so this has
        // to win the gesture rather than opening the order underneath.
        child: GestureDetector(
          onTap: _show,
          behavior: HitTestBehavior.opaque,
          child: widget.child,
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final media = MediaQuery.of(context);
    final gutter = AppPadding.pW20;
    final width = media.size.width - gutter * 2;
    // Sits ABOVE the control: the address underneath is the one thing the
    // courier opened the card to read, and a hint must never land on it.
    final bottom = media.size.height - _anchor.top + AppPadding.pH8;
    // Where the control falls across the bubble, as Alignment's -1…1. Both the
    // caret and the scale origin use it, so the bubble unfolds from the icon
    // however near the edge that icon sits.
    final originX = width <= 0
        ? 0.0
        : (((_anchor.center.dx - gutter) / width).clamp(0.0, 1.0) * 2 - 1);

    return Stack(
      children: [
        // Anywhere else dismisses it early.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hideNow,
          ),
        ),
        Positioned(
          left: gutter,
          right: gutter,
          bottom: bottom,
          child: AnimatedBuilder(
            animation: _curve,
            builder: (context, child) {
              final t = _curve.value;
              return Opacity(
                opacity: t.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, AppSize.sH6 * (1 - t)),
                  child: Transform.scale(
                    // From 92%, not from nothing: a bubble that grows from a
                    // point reads as a pop, and this is an aside.
                    scale: 0.92 + 0.08 * t,
                    alignment: Alignment(originX, 1),
                    child: child,
                  ),
                ),
              );
            },
            child: _HintBubble(message: widget.message, originX: originX),
          ),
        ),
      ],
    );
  }
}

/// The bubble itself — an ink panel with a caret dropped under the control it
/// came from.
class _HintBubble extends StatelessWidget {
  const _HintBubble({required this.message, required this.originX});

  final String message;

  /// -1…1 across the bubble; where the caret sits.
  final double originX;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inkFill,
            borderRadius: BorderRadius.circular(AppCircular.r12),
            boxShadow: AppShadows.card,
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
        Align(
          alignment: Alignment(originX, 0),
          child: CustomPaint(
            size: Size(12.w, AppSize.sH6),
            painter: const _CaretPainter(color: AppColors.inkFill),
          ),
        ),
      ],
    );
  }
}

/// The downward caret joining the bubble to its control.
class _CaretPainter extends CustomPainter {
  const _CaretPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CaretPainter old) => old.color != color;
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
