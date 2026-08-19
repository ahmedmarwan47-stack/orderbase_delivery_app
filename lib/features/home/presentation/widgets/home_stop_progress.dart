part of '../imports/home_imports.dart';

/// The next-stop hero's progress bar: one segment per route stop, coloured by
/// status (green = delivered · red = failed · ink = the current stop · faint
/// grey = upcoming). Each segment keeps the fade-on-close colour animation, and
/// tapping one pops a small animated tooltip that explains *why* that segment is
/// the colour it is (+ which order it maps to). The tooltip is an overlay so it
/// can float above the card; it auto-dismisses and closes on any outside tap.
class _HomeStopProgress extends StatefulWidget {
  const _HomeStopProgress({required this.stops, required this.current});

  /// Route stops in reading order (closed → current → upcoming).
  final List<Order> stops;

  /// The stop the courier is on now — used to colour/label the ink segment.
  final Order current;

  @override
  State<_HomeStopProgress> createState() => _HomeStopProgressState();
}

class _HomeStopProgressState extends State<_HomeStopProgress>
    with TickerProviderStateMixin {
  late final AnimationController _tipCtrl = AnimationController(
    vsync: this,
    duration: AppMotion.stamp,
  );
  late final Animation<double> _tip = CurvedAnimation(
    parent: _tipCtrl,
    curve: AppMotion.ease,
  );

  /// Drives the current stop's fill — the ink segment fills from empty to full
  /// width, loops, and refills, so the stop the courier is on keeps "charging".
  late final AnimationController _sweepCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// One anchor link per segment so a tooltip can follow its own bar.
  final Map<int, LayerLink> _links = {};
  OverlayEntry? _entry;
  int? _openIndex;
  Timer? _autoHide;

  LayerLink _link(int i) => _links.putIfAbsent(i, LayerLink.new);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Loop the sweep, unless the user asked for reduced motion (then hold still).
    if (AppMotion.reduced(context)) {
      _sweepCtrl.stop();
    } else if (!_sweepCtrl.isAnimating) {
      _sweepCtrl.repeat();
    }
  }

  @override
  void dispose() {
    _autoHide?.cancel();
    _entry?.remove();
    _entry = null;
    _tipCtrl.dispose();
    _sweepCtrl.dispose();
    super.dispose();
  }

  void _onTapSeg(int i, Order stop) {
    // Second tap on the open segment closes it; otherwise (re)open on this one.
    if (_openIndex == i) {
      _hideTip();
      return;
    }
    AppHaptics.tick();
    _showTip(i, stop);
  }

  void _showTip(int i, Order stop) {
    _autoHide?.cancel();
    _entry?.remove();
    _openIndex = i;
    _entry = OverlayEntry(
      builder: (_) => _HomeProgressTip(
        link: _link(i),
        animation: _tip,
        title: _segLabel(stop, widget.current),
        orderNo: LocaleKeys.homeOrderNo.tr(
          namedArgs: {'num': stop.num.replaceAll('#', '')},
        ),
        onDismiss: _hideTip,
      ),
    );
    Overlay.of(context).insert(_entry!);
    if (AppMotion.reduced(context)) {
      _tipCtrl.value = 1;
    } else {
      _tipCtrl.forward(from: 0);
    }
    // Fade back out on its own if the courier just glances at it.
    _autoHide = Timer(const Duration(milliseconds: 2600), _hideTip);
  }

  void _hideTip() {
    _autoHide?.cancel();
    final entry = _entry;
    if (entry == null) return;
    if (!mounted || AppMotion.reduced(context)) {
      _removeEntry(entry);
      return;
    }
    _tipCtrl.reverse().whenComplete(() {
      if (identical(_entry, entry)) _removeEntry(entry);
    });
  }

  void _removeEntry(OverlayEntry entry) {
    entry.remove();
    if (identical(_entry, entry)) {
      _entry = null;
      _openIndex = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        // Half the bar-to-map gap; the rest is the per-segment tap padding below,
        // so the visible bar stays exactly where it was before it was tappable.
        bottom: AppPadding.pH8,
      ),
      child: Row(
        spacing: AppSize.sW8,
        children: [
          for (final (i, s) in widget.stops.indexed)
            Expanded(
              child: CompositedTransformTarget(
                link: _link(i),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _onTapSeg(i, s),
                  // Transparent vertical padding grows the 6px bar's hit target
                  // to ~22px without moving it (the card compensates 8px above).
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppPadding.pH8),
                    child: TweenAnimationBuilder<Color?>(
                      key: ValueKey(s.num),
                      tween: ColorTween(
                        begin: _segColor(s, widget.current),
                        end: _segColor(s, widget.current),
                      ),
                      duration: reduced ? Duration.zero : AppMotion.fill,
                      curve: AppMotion.ease,
                      builder: (context, color, _) {
                        final base = _segColor(s, widget.current);
                        // Only the current stop (the ink segment) animates: it
                        // fills from zero to its full width, over and over. Every
                        // other segment stays a static colour.
                        final isCurrent = base == AppColors.inkFill;
                        if (reduced || !isCurrent) {
                          return _HomeProgressSeg(color ?? base);
                        }
                        return AnimatedBuilder(
                          animation: _sweepCtrl,
                          builder: (context, _) {
                            // Ease the fill in over the first 80% of the loop,
                            // hold full briefly, then restart.
                            final fill = Curves.easeInOut.transform(
                              (_sweepCtrl.value / 0.8).clamp(0.0, 1.0),
                            );
                            return Stack(
                              children: [
                                const _HomeProgressSeg(AppColors.borderDefault),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: FractionallySizedBox(
                                    widthFactor: fill,
                                    child: const _HomeProgressSeg(
                                      AppColors.inkFill,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Progress-segment colour: delivered → green, failed → red, the current stop
  /// → ink (kept distinct from the failed red so two reds never sit on the same
  /// bar), upcoming stops → the faint track.
  static Color _segColor(Order stop, Order current) {
    if (stop.status == OrderStatus.delivered) return AppColors.greenAccent;
    if (stop.status == OrderStatus.failed) return AppColors.failedText;
    if (stop.num == current.num) return AppColors.inkFill;
    return AppColors.borderDefault;
  }

  /// The tooltip's headline — the plain-language reason for the colour.
  static String _segLabel(Order stop, Order current) {
    if (stop.status == OrderStatus.delivered) {
      return LocaleKeys.homeProgressDelivered.tr();
    }
    if (stop.status == OrderStatus.failed) {
      return LocaleKeys.homeProgressFailed.tr();
    }
    if (stop.num == current.num) return LocaleKeys.homeProgressCurrent.tr();
    return LocaleKeys.homeProgressUpcoming.tr();
  }
}

/// The floating tooltip: a status headline + order number in a dark bubble with
/// a little downward pointer, anchored above the tapped segment. Fades and scales
/// up from the bar; a full-screen barrier behind it closes it on outside taps.
class _HomeProgressTip extends StatelessWidget {
  const _HomeProgressTip({
    required this.link,
    required this.animation,
    required this.title,
    required this.orderNo,
    required this.onDismiss,
  });

  final LayerLink link;
  final Animation<double> animation;
  final String title;
  final String orderNo;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Outside-tap catcher — a tap anywhere off the bubble dismisses.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onDismiss,
          ),
        ),
        Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.topCenter,
            followerAnchor: Alignment.bottomCenter,
            offset: const Offset(0, -4),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.85, end: 1).animate(animation),
                  alignment: Alignment.bottomCenter,
                  child: _bubble(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Wrapped in a transparent [Material] so overlay text inherits a proper
  // DefaultTextStyle (a bare Overlay otherwise paints the yellow "missing
  // style" underline under every glyph).
  // Dark "ink" bubble so it stands clear of the white hero card, with a matching
  // pointer. Wrapped in a transparent [Material] so overlay text inherits a
  // proper DefaultTextStyle (a bare Overlay otherwise paints the yellow "missing
  // style" underline under every glyph).
  Widget _bubble() => Material(
    type: MaterialType.transparency,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 220.w),
          decoration: BoxDecoration(
            color: AppColors.inkFill,
            borderRadius: BorderRadius.circular(AppCircular.r12),
            boxShadow: AppShadows.heroCard,
          ),
          child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: const TextStyle().setWhite.s14.semiBold),
                  4.szH,
                  Text(
                    orderNo,
                    style: const TextStyle()
                        .setColor(AppColors.onInkMuted)
                        .s12
                        .regular
                        .tabular,
                  ),
                ],
              ).paddingSymmetric(
                horizontal: AppPadding.pW12,
                vertical: AppPadding.pH8,
              ),
        ),
        CustomPaint(
          size: Size(AppSize.sW14, AppSize.sH8),
          painter: const _TipArrowPainter(color: AppColors.inkFill),
        ),
      ],
    ),
  );
}

/// A small downward triangle in the bubble's colour that joins it to the segment.
class _TipArrowPainter extends CustomPainter {
  const _TipArrowPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final tri = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(tri, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TipArrowPainter old) => old.color != color;
}
