part of '../imports/order_flow_imports.dart';

/// The three outcomes of a delivery attempt, shown on the result screen.
enum ResultKind { delivered, failed, postponed }

/// Result — Order Flow terminal step (Order Flow.dc.html, `isResult`).
/// A centered outcome screen with a tinted badge, a summary card whose last
/// row is variant-specific, and two follow-up actions. Defaults match the
/// mockup's sample data for order #89289 (Arabic defaults resolve through
/// [LocaleKeys] when not supplied).
///
/// The arrival is authored (see [_ResultScreenState]): photo/badge, verdict,
/// summary, and actions settle in a short capped stagger so closing a stop
/// *feels* complete. Each outcome carries the motion at a different weight —
/// a calm settle for delivered, a quieter one for failed — and the whole
/// sequence collapses to instant when the platform asks to reduce motion.
class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    this.kind = ResultKind.delivered,
    this.orderNum = '#89289',
    this.customer = 'محمد حمدي',
    this.codAmount,
    this.showWalletChange = true,
    this.walletChange,
    this.reasonLabel,
    this.postponeDisplay,
    this.onContinue,
    this.onHome,
  });

  final ResultKind kind;
  final String orderNum;
  final String customer;
  final String? codAmount;
  final bool showWalletChange;
  final String? walletChange;
  final String? reasonLabel;
  final String? postponeDisplay;
  final VoidCallback? onContinue;
  final VoidCallback? onHome;

  @override
  State<ResultScreen> createState() => _ResultScreenState();

  Color get _tint => switch (kind) {
        ResultKind.delivered => AppColors.greenAccent,
        ResultKind.postponed => AppColors.postponedText,
        ResultKind.failed => AppColors.brand,
      };

  Color get _tintBg => switch (kind) {
        ResultKind.delivered => AppColors.deliveredBg,
        ResultKind.postponed => AppColors.heroCodPillBg,
        ResultKind.failed => AppColors.failedBg,
      };

  String get _icon => switch (kind) {
        ResultKind.delivered => AppAssets.svg.check,
        ResultKind.postponed => AppAssets.svg.clock,
        ResultKind.failed => AppAssets.svg.fail,
      };

  /// Delivered / failed show the isolated result photo; postponed keeps the
  /// tinted clock badge.
  Widget _badge() {
    final photo = switch (kind) {
      ResultKind.delivered => AppAssets.img.resultSuccess,
      ResultKind.failed => AppAssets.img.resultFailure,
      ResultKind.postponed => null,
    };
    if (photo != null) {
      return Image.asset(photo, height: 168.h, fit: BoxFit.contain);
    }
    return Container(
      width: AppSize.sW88 + AppSize.sW8, // 96 badge
      height: AppSize.sH88 + AppSize.sH8,
      decoration: BoxDecoration(color: _tintBg, shape: BoxShape.circle),
      child: Center(
        child: IconWidget(
          icon: _icon,
          color: _tint,
          height: 52.h, // large badge glyph
          width: 52.w,
        ),
      ),
    );
  }

  String get _title => switch (kind) {
        ResultKind.delivered => LocaleKeys.resultDeliveredTitle,
        ResultKind.postponed => LocaleKeys.resultPostponedTitle,
        ResultKind.failed => LocaleKeys.resultFailedTitle,
      }
          .tr();

  String get _sub => switch (kind) {
        ResultKind.delivered => LocaleKeys.resultDeliveredSub,
        ResultKind.postponed => LocaleKeys.resultPostponedSub,
        ResultKind.failed => LocaleKeys.resultFailedSub,
      }
          .tr();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  /// Motion character by outcome: delivered gets the fullest, calmest settle;
  /// failed the shortest and quietest; postponed sits between.
  Duration get _entranceDuration => switch (widget.kind) {
        ResultKind.delivered => const Duration(milliseconds: 500),
        ResultKind.postponed => const Duration(milliseconds: 460),
        ResultKind.failed => const Duration(milliseconds: 420),
      };

  /// How far the photo/badge scales up on entry — a fuller settle for a
  /// delivered handoff, barely any for a failed one. Delivered starts a touch
  /// lower so the press-in reads as a stamp.
  double get _badgeScaleFrom => switch (widget.kind) {
        ResultKind.delivered => 0.88,
        ResultKind.postponed => 0.93,
        ResultKind.failed => 0.96,
      };

  /// Fires the outcome haptic exactly once on arrival — the "stamp". Haptics
  /// are feedback, so this runs regardless of Reduce Motion.
  bool _stamped = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: _entranceDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The stamp: one outcome haptic on first appearance, never on rebuild.
    if (!_stamped) {
      _stamped = true;
      switch (widget.kind) {
        case ResultKind.delivered:
          AppHaptics.success();
        case ResultKind.failed:
          AppHaptics.warning();
        case ResultKind.postponed:
          AppHaptics.confirm();
      }
    }
    // Honor Reduce Motion: jump to the settled state instead of animating.
    if (MediaQuery.of(context).disableAnimations) {
      _entrance.value = 1;
    } else if (_entrance.status == AnimationStatus.dismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Wraps [child] in a capped, interval-gated fade + rise (+ optional scale)
  /// driven by [_entrance]. Exponential ease-out; the settled default (t=1) is
  /// a plain, fully-visible child, so a stalled controller never strands
  /// content.
  Widget _rise({
    required double begin,
    required double end,
    double dy = 10,
    double scaleFrom = 1.0,
    required Widget child,
  }) {
    final interval = Interval(begin, end, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: _entrance,
      child: child,
      builder: (_, ch) {
        final t = interval.transform(_entrance.value);
        Widget out = Transform.translate(
          offset: Offset(0, (1 - t) * dy),
          child: ch,
        );
        if (scaleFrom != 1.0) {
          out = Transform.scale(
            scale: scaleFrom + (1 - scaleFrom) * t,
            child: out,
          );
        }
        return Opacity(opacity: t, child: out);
      },
    );
  }

  /// Badge-only stamp emphasis: scales up from [_badgeScaleFrom] through a
  /// slight, capped overshoot (~1.04) and eases back to 1 — a brief press that
  /// reads like stamping the manifest, not a bounce. Driven over the badge's
  /// own window (matching the [_rise] interval below) on [AppMotion.ease]. The
  /// settled value (t=1) is exactly 1.0, so Reduce Motion — which pins the
  /// controller to 1 — lands on the badge at rest with no scaling.
  Widget _badgeStamp(Widget child) {
    const window = Interval(0, 0.55, curve: AppMotion.ease);
    const overshoot = 1.04;
    const settlePoint = 0.82; // fraction of the window spent growing in
    return AnimatedBuilder(
      animation: _entrance,
      child: child,
      builder: (_, ch) {
        final t = window.transform(_entrance.value);
        final double scale = t < settlePoint
            ? _badgeScaleFrom +
                (overshoot - _badgeScaleFrom) * (t / settlePoint)
            : overshoot +
                (1.0 - overshoot) * ((t - settlePoint) / (1 - settlePoint));
        return Transform.scale(scale: scale, child: ch);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _rise(
                        begin: 0,
                        end: 0.55,
                        dy: 6,
                        child: _badgeStamp(widget._badge()),
                      ),
                    ),
                    20.szH,
                    _rise(
                      begin: 0.12,
                      end: 0.6,
                      child: Text(
                        widget._title,
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle().setMainTextColor.s20.bold,
                      ),
                    ),
                    8.szH,
                    _rise(
                      begin: 0.22,
                      end: 0.72,
                      child: Text(
                        widget._sub,
                        textAlign: TextAlign.center,
                        style: const TextStyle()
                            .setSecondaryColor
                            .s14
                            .regular
                            .withHeight(1.5),
                      ),
                    ),
                    20.szH,
                    _rise(
                      begin: 0.34,
                      end: 0.9,
                      dy: 12,
                      child: _ResultSummaryCard(
                        kind: widget.kind,
                        orderNum: widget.orderNum,
                        customer: widget.customer,
                        codAmount:
                            widget.codAmount ?? LocaleKeys.resultDefaultCod.tr(),
                        showWalletChange: widget.showWalletChange,
                        walletChange: widget.walletChange ??
                            LocaleKeys.resultDefaultWallet.tr(),
                        reasonLabel: widget.reasonLabel ??
                            LocaleKeys.resultDefaultReason.tr(),
                        postponeDisplay: widget.postponeDisplay ??
                            LocaleKeys.resultDefaultPostpone.tr(),
                      ),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 36.w), // wide mockup gutter
              ),
              _rise(
                begin: 0.46,
                end: 1.0,
                dy: 12,
                child: _ResultActions(
                  onContinue: widget.onContinue,
                  onHome: widget.onHome,
                ),
              ),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
