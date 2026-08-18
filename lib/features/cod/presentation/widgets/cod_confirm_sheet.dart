part of '../imports/cod_imports.dart';

/// COD 2a — screen 2: confirm the collected cash. Spells out the wallet top-up
/// and what the courier hands over at end-of-day settlement, then confirms the
/// delivery. "تعديل المبلغ" pops `false` to reopen the keypad.
///
/// The settlement math resolves as it arrives: the summary card fades up and
/// the heavy ink cash card settles in just after, so the "in your custody"
/// figure lands with weight. Collapses to instant under Reduce Motion.
class _CodConfirmSheet extends StatefulWidget {
  const _CodConfirmSheet({required this.due, required this.amount});

  final int due;
  final int amount;

  @override
  State<_CodConfirmSheet> createState() => _CodConfirmSheetState();
}

class _CodConfirmSheetState extends State<_CodConfirmSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;

  /// The success haptic (money landing) fires exactly once, on first settle.
  bool _settledOnce = false;

  int get due => widget.due;
  int get amount => widget.amount;
  int get extra => amount > due ? amount - due : 0;
  bool get hasExtra => extra > 0;

  String get _unit => LocaleKeys.codUnit.tr();

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _reveal.value = 1;
    } else if (_reveal.status == AnimationStatus.dismissed) {
      _reveal.forward();
    }
    // Money landing: one success haptic on first settle. Feedback, not motion,
    // so it fires under Reduce Motion too.
    if (!_settledOnce) {
      _settledOnce = true;
      AppHaptics.success();
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  /// Interval-gated fade (+ optional rise / settle-scale) on the reveal
  /// controller. Settled default (t=1) is a plain, fully-visible child.
  Widget _reveals({
    required double begin,
    required double end,
    double dy = 0,
    double scaleFrom = 1.0,
    required Widget child,
  }) {
    final interval = Interval(begin, end, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: _reveal,
      child: child,
      builder: (_, ch) {
        final t = interval.transform(_reveal.value);
        Widget out = ch!;
        if (dy != 0) {
          out = Transform.translate(offset: Offset(0, (1 - t) * dy), child: out);
        }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppCircular.r26)),
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
          Center(
            child: Container(
              width: 42.w,
              height: 5.h,
              margin: EdgeInsets.symmetric(vertical: AppMargin.mH8),
              decoration: BoxDecoration(
                color: AppColors.sheetGrabber,
                borderRadius: BorderRadius.circular(AppCircular.r3),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  8.szH,
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      width: AppSize.sW56,
                      height: AppSize.sH56,
                      decoration: BoxDecoration(
                        color: AppColors.postponedBg,
                        borderRadius: BorderRadius.circular(AppCircular.r16),
                      ),
                      child: Center(
                        child: IconWidget(
                          icon: AppAssets.svg.wallet,
                          color: AppColors.postponedText,
                          height: AppSize.sH28,
                          width: AppSize.sW28,
                        ),
                      ),
                    ),
                  ),
                  16.szH,
                  Text(
                    hasExtra
                        ? LocaleKeys.codSheetTitleExtra
                            .tr(namedArgs: {'amount': formatThousands(extra)})
                        : LocaleKeys.codSheetTitleMatch.tr(),
                    style: const TextStyle().setMainTextColor.s20.extraBold,
                  ),
                  8.szH,
                  Text(
                    hasExtra
                        ? LocaleKeys.codSheetBodyExtra
                            .tr(namedArgs: {'total': formatThousands(amount)})
                        : LocaleKeys.codSheetBodyMatch.tr(),
                    style: const TextStyle()
                        .setSecondaryColor
                        .s14
                        .regular
                        .withHeight(1.5),
                  ),
                  20.szH,
                  _reveals(begin: 0, end: 0.6, dy: 6, child: _summaryCard()),
                  16.szH,
                  // The heavy ink cash card is the moment: it settles in
                  // (fade + a small scale) just after the math above.
                  _reveals(
                    begin: 0.28,
                    end: 1.0,
                    scaleFrom: 0.96,
                    child: _settlementCard(),
                  ),
                  16.szH,
                  _PrimaryButton(
                    label: LocaleKeys.codConfirmDelivery.tr(),
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                  8.szH,
                  _GhostButton(
                    label: LocaleKeys.codEditAmount.tr(),
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: LocaleKeys.codSummaryCollected.tr(),
            value: '${formatThousands(amount)} $_unit',
            emphasize: true,
          ),
          12.szH,
          _SummaryRow(
            label: LocaleKeys.codSummaryOrderValue.tr(),
            value: '${formatThousands(due)} $_unit',
          ),
          12.szH,
          _SummaryRow(
            label: LocaleKeys.codSummaryToWallet.tr(),
            value: '${formatThousands(extra)} $_unit',
            accent: AppColors.postponedText,
            leadingIcon: AppAssets.svg.wallet,
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }

  /// Dark card: what the courier carries and hands over at settlement.
  Widget _settlementCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.codSettlementLabel.tr(),
                  style:
                      const TextStyle().setColor(AppColors.paymentLabel).s12.regular,
                ),
                4.szH,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    CountUpText(
                      value: amount,
                      format: formatThousands,
                      textDirection: TextDirection.ltr,
                      duration: AppMotion.focal,
                      animate: !AppMotion.reduced(context),
                      style: const TextStyle()
                          .setWhite
                          .s20
                          .extraBold
                          .withHeight(1)
                          .tabular,
                    ),
                    4.szW,
                    Text(
                      _unit,
                      style: const TextStyle()
                          .setColor(AppColors.paymentSuffix)
                          .s14
                          .bold,
                    ),
                  ],
                ),
                4.szH,
                Text(
                  LocaleKeys.codSettlementBreakdown.tr(namedArgs: {
                    'due': formatThousands(due),
                    'extra': formatThousands(extra),
                  }),
                  style:
                      const TextStyle().setColor(AppColors.paymentLabel).s12.regular,
                ),
              ],
            ),
          ),
          12.szW,
          _cashTile(),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW20, vertical: AppPadding.pH16),
    );
  }

  /// The green cash tile. As the card settles it gives one subtle, confident
  /// pulse (scale 1→1.12→1) over the tail of the reveal. No pulse under Reduce
  /// Motion.
  Widget _cashTile() {
    final tile = Container(
      width: AppSize.sW44,
      height: AppSize.sH44,
      decoration: BoxDecoration(
        color: AppColors.paymentTile,
        borderRadius: BorderRadius.circular(AppCircular.r14),
      ),
      child: Center(
        child: IconWidget(
          icon: AppAssets.svg.cash,
          color: AppColors.cashBright,
          height: AppSize.sH22,
          width: AppSize.sW22,
        ),
      ),
    );
    if (AppMotion.reduced(context)) return tile;
    const interval = Interval(0.66, 1.0, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: _reveal,
      child: tile,
      builder: (_, ch) {
        final p = interval.transform(_reveal.value);
        // Triangle: up to the peak at the midpoint, back down by the tail.
        final tri = p < 0.5 ? p * 2 : (1 - p) * 2;
        return Transform.scale(scale: 1 + 0.12 * tri, child: ch);
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.accent,
    this.leadingIcon,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? accent;
  final String? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final valueColor = accent ?? AppColors.textPrimary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              IconWidget(
                icon: leadingIcon!,
                color: accent ?? AppColors.textSecondary,
                height: AppSize.sH16,
                width: AppSize.sW16,
              ),
              8.szW,
            ],
            Text(label,
                style: const TextStyle().setSecondaryColor.s14.regular),
          ],
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: emphasize
              ? const TextStyle().setColor(valueColor).s16.extraBold.tabular
              : const TextStyle().setColor(valueColor).s14.bold.tabular,
        ),
      ],
    );
  }
}

/// Ink-black full-width confirm button (COD screens use a 16px radius).
class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        height: AppSize.sH56,
        decoration: BoxDecoration(
          color: AppColors.inkFill,
          borderRadius: BorderRadius.circular(AppCircular.r16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconWidget(
              icon: AppAssets.svg.check,
              color: AppColors.surface,
              height: AppSize.sH20,
              width: AppSize.sW20,
            ),
            8.szW,
            Text(label, style: const TextStyle().setWhite.s14.bold),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: AppSize.sH48,
        child: Center(
          child: Text(
            label,
            style: const TextStyle().setTertiaryColor.s14.bold,
          ),
        ),
      ).onClick(onTap: onTap),
    );
  }
}
