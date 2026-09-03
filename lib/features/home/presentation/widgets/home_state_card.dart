part of '../imports/home_imports.dart';

/// What Home shows in the hero's place when there is nothing to deliver — one
/// card, three states, so the page always says what the courier should be
/// doing now:
///
///  * **idle** — no batch dispatched yet. The branch, and a line saying one
///    will be announced.
///  * **returning** — everything in hand is closed. «ارجع للفرع» with the
///    return estimate, what to hand over (cash and returns), the map pointing
///    at the branch, and a call-the-branch button.
///  * **settled** — the branch closed the day. Who took the cash and when, and
///    (dev only) a way to start the simulated day again.
///
/// A batch waiting at the branch adds the amber «ارجع للفرع لاستلام دفعة»
/// row to any of the three, since collecting it is then the next thing to do.
/// That row also rides under the hero while the courier is still on route —
/// see [HomeScreen].
class _HomeStateCard extends StatelessWidget {
  const _HomeStateCard({
    required this.status,
    this.onCallBranch,
    this.onOpenPendingBatch,
    this.onStartNewDay,
  });

  final CourierStatus status;
  final VoidCallback? onCallBranch;
  final VoidCallback? onOpenPendingBatch;
  final VoidCallback? onStartNewDay;

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r22),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: switch (status) {
        CourierStatus.returning => _ReturningBody(
          shift: shift,
          onCallBranch: onCallBranch,
          onOpenPendingBatch: onOpenPendingBatch,
        ),
        CourierStatus.settled => _SettledBody(
          shift: shift,
          onOpenPendingBatch: onOpenPendingBatch,
          onStartNewDay: onStartNewDay,
        ),
        CourierStatus.idle || CourierStatus.onRoute => _IdleBody(
          shift: shift,
          onOpenPendingBatch: onOpenPendingBatch,
        ),
      },
    );
  }
}

/// Before the first batch: the branch, and that a batch will be announced.
class _IdleBody extends StatelessWidget {
  const _IdleBody({required this.shift, this.onOpenPendingBatch});
  final ShiftController shift;
  final VoidCallback? onOpenPendingBatch;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StateGlyph(icon: AppAssets.svg.box),
        16.szH,
        Text(
          LocaleKeys.homeIdleTitle.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle().setMainTextColor.s16.bold,
        ),
        8.szH,
        Text(
          '${Courier.merchantName} · ${shift.branchName}',
          textAlign: TextAlign.center,
          style: const TextStyle().setTertiaryColor.s14.semiBold,
        ),
        8.szH,
        Text(
          LocaleKeys.homeIdleBody.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
            1.5,
          ),
        ),
        if (shift.hasPendingBatch) ...[
          16.szH,
          _PendingBatchRow(onTap: onOpenPendingBatch),
        ],
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW20, vertical: AppPadding.pH32);
  }
}

/// Everything in hand is closed: head back to the branch.
class _ReturningBody extends StatelessWidget {
  const _ReturningBody({
    required this.shift,
    this.onCallBranch,
    this.onOpenPendingBatch,
  });
  final ShiftController shift;
  final VoidCallback? onCallBranch;
  final VoidCallback? onOpenPendingBatch;

  @override
  Widget build(BuildContext context) {
    final batch = shift.currentBatch;
    final eta = shift.returnEtaLabel ?? '';
    final cash = shift.cashInHand;
    final returns = shift.pendingReturns.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The batch, closed. Its trip row is off: the ride back is the
            // whole point of this card and is stated once, in the pill below.
            if (batch != null)
              _HomeBatchLine(
                batch: batch,
                current: shift.totalStops,
                total: shift.totalStops,
                returnEta: eta,
                routeKm: batch.routeKm,
                done: true,
                showTrip: false,
              ),
            12.szH,
            // Instruction and the one time it names. The branch's name, and
            // the reason for going, are left out: the map below is the branch
            // and the chips under it are the reason.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    LocaleKeys.homeReturnTitle.tr(),
                    style: const TextStyle().setMainTextColor.s16.bold
                        .withHeight(1.3),
                  ),
                ),
                12.szW,
                _ExpectedAtPill(eta: eta),
              ],
            ),
          ],
        ).paddingOnly(
          left: AppPadding.pW20,
          top: AppPadding.pH16,
          right: AppPadding.pW20,
          bottom: AppPadding.pH12,
        ),
        // The map points at the branch now, not a customer — the ink pin
        // (rather than the brand red) says "yours", not "theirs".
        MapView(
          height: AppSize.sH120,
          showHairlines: true,
          destinationLabel: shift.branchAddress,
          pinColor: AppColors.inkFill,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  LocaleKeys.homeHandToBranch.tr(),
                  style: const TextStyle().setSecondaryColor.s12.regular,
                ),
                8.szW,
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: AppSize.sW6,
                    runSpacing: AppSize.sH4,
                    children: [
                      _HandChip(
                        text: LocaleKeys.homeReturnHandCash.tr(
                          namedArgs: {'amount': formatThousands(cash)},
                        ),
                        alert: shift.overCashLimit,
                      ),
                      if (returns > 0)
                        _HandChip(
                          text: LocaleKeys.homeReturnHandReturns.tr(
                            namedArgs: {'count': arabicDigits(returns)},
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (shift.hasPendingBatch) ...[
              12.szH,
              // Already told to go back, so this row only names what is there.
              _PendingBatchRow(onTap: onOpenPendingBatch, returning: true),
            ],
            12.szH,
            _OutlineButton(
              icon: AppAssets.svg.phone,
              label: LocaleKeys.homeCallBranch.tr(),
              onTap: onCallBranch,
            ),
          ],
        ).paddingOnly(
          left: AppPadding.pW20,
          top: AppPadding.pH12,
          right: AppPadding.pW20,
          bottom: AppPadding.pH16,
        ),
      ],
    );
  }
}

/// «متوقَّع ~٥:٤٤ م» — the estimate, stated once and only here. The header
/// says «متوقَّع في الفرع» with no time, and the title beside this pill has
/// already named the branch, so neither the phrase nor the figure is printed
/// twice on one screen.
class _ExpectedAtPill extends StatelessWidget {
  const _ExpectedAtPill({required this.eta});
  final String eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.transitPillBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH4,
      ),
      child: Text(
        LocaleKeys.homeReturnExpected.tr(namedArgs: {'time': eta}),
        style: const TextStyle()
            .setColor(AppColors.transitBg)
            .s12
            .semiBold
            .tabular,
      ),
    );
  }
}

/// The branch settled the day.
class _SettledBody extends StatelessWidget {
  const _SettledBody({
    required this.shift,
    this.onOpenPendingBatch,
    this.onStartNewDay,
  });
  final ShiftController shift;
  final VoidCallback? onOpenPendingBatch;
  final VoidCallback? onStartNewDay;

  @override
  Widget build(BuildContext context) {
    final receipt = shift.settlement;
    return Column(
      children: [
        // The slate check settles in once — a single scale + fade arrival.
        TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: AppMotion.reduced(context) ? 1.0 : 0.0,
            end: 1.0,
          ),
          duration: AppMotion.reduced(context)
              ? Duration.zero
              : AppMotion.settle,
          curve: AppMotion.ease,
          builder: (context, t, child) => Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: Transform.scale(scale: t, child: child),
          ),
          child: const _StateGlyph(
            icon: null,
            background: AppColors.paymentCardBg,
            foreground: AppColors.surface,
          ),
        ),
        16.szH,
        Text(
          LocaleKeys.homeSettledTitle.tr(),
          textAlign: TextAlign.center,
          style: const TextStyle().setMainTextColor.s16.bold,
        ),
        8.szH,
        Text(
          receipt == null
              ? LocaleKeys.homeSettledBodyPlain.tr()
              : LocaleKeys.homeSettledBody.tr(
                  namedArgs: {
                    'cashier': receipt.cashier,
                    'cash': formatThousands(receipt.cash),
                    'time': formatClockArabic(receipt.at),
                  },
                ),
          textAlign: TextAlign.center,
          style: const TextStyle().setSecondaryColor.s14.regular.withHeight(
            1.5,
          ),
        ),
        8.szH,
        Text(
          LocaleKeys.homeRouteCompleteStats.tr(
            namedArgs: {
              'done': arabicDigits(shift.deliveredCount),
              'total': arabicDigits(shift.orders.length),
              'cash': formatThousands(shift.collectedEgp),
            },
          ),
          textAlign: TextAlign.center,
          style: const TextStyle().setTertiaryColor.s12.semiBold,
        ),
        if (shift.hasPendingBatch) ...[
          16.szH,
          _PendingBatchRow(onTap: onOpenPendingBatch),
        ],
        if (onStartNewDay != null) ...[
          16.szH,
          _OutlineButton(
            icon: AppAssets.svg.undo,
            label: LocaleKeys.homeStartNewDay.tr(),
            onTap: onStartNewDay,
          ),
        ],
      ],
    ).paddingSymmetric(horizontal: AppPadding.pW20, vertical: AppPadding.pH32);
  }
}

/// 64pt round glyph tile at the top of the centred states.
class _StateGlyph extends StatelessWidget {
  const _StateGlyph({
    required this.icon,
    this.background = AppColors.surfaceMuted,
    this.foreground = AppColors.textTertiary,
  });

  /// Null draws the check.
  final String? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sW64,
      height: AppSize.sH64,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      child: Center(
        child: IconWidget(
          icon: icon ?? AppAssets.svg.check,
          color: foreground,
          height: AppSize.sH28,
          width: AppSize.sW28,
        ),
      ),
    );
  }
}

/// «1,250 جم نقدًا» / «٣ مرتجعات» — what the courier hands the branch. The
/// cash chip goes red over the limit, like the figure everywhere else.
class _HandChip extends StatelessWidget {
  const _HandChip({required this.text, this.alert = false});
  final String text;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: alert ? AppColors.failedBg : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH4,
      ),
      child: Text(
        text,
        style: const TextStyle()
            .setColor(alert ? AppColors.failedText : AppColors.textTertiary)
            .s12
            .semiBold
            .tabular,
      ),
    );
  }
}

/// «ارجع للفرع لاستلام دفعة جديدة» — shown wherever Home is, on route or not.
///
/// A batch dispatched mid-route is a reason to turn around *now*: the orders
/// are not in the bag, and nothing else on Home would say so while the hero is
/// busy with the stop in hand. So this row rides under the hero as well as
/// inside the status card, and names what is waiting so the courier can judge
/// whether it is worth the detour yet.
class _PendingBatchRow extends StatelessWidget {
  const _PendingBatchRow({this.onTap, this.returning = false});
  final VoidCallback? onTap;

  /// The courier has already been told to head back, so the row drops the
  /// instruction and just names what is waiting.
  final bool returning;

  @override
  Widget build(BuildContext context) {
    final pending = ShiftController.instance.pendingBatches;
    if (pending.isEmpty) return const SizedBox.shrink();
    final orders = pending.fold<int>(0, (sum, b) => sum + b.count);
    final cash = pending.fold<int>(0, (sum, b) => sum + b.codTotal);
    final meta = LocaleKeys.homeCollectBatchMeta.tr(
      namedArgs: {
        // One waiting batch is named; several are counted, since a list of
        // IDs would say less than "two batches" at this size.
        'what': pending.length == 1
            ? pending.single.id
            : LocaleKeys.homeCollectBatchCount.tr(
                namedArgs: {'n': arabicDigits(pending.length)},
              ),
        'orders': arabicDigits(orders),
        'cash': formatThousands(cash),
      },
    );
    return Semantics(
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.postponedBannerBg,
          borderRadius: BorderRadius.circular(AppCircular.r16),
          border: Border.all(color: AppColors.postponedBorder),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW16,
          vertical: AppPadding.pH12,
        ),
        child: Row(
          children: [
            IconWidget(
              icon: AppAssets.svg.store,
              color: AppColors.postponedText,
              height: AppSize.sH20,
              width: AppSize.sW20,
            ),
            12.szW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (returning
                            ? LocaleKeys.homeCollectBatchReady
                            : LocaleKeys.homeCollectBatchTitle)
                        .tr(),
                    style: const TextStyle()
                        .setColor(AppColors.postponedText)
                        .s14
                        .semiBold,
                  ),
                  2.szH,
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle()
                        .setColor(AppColors.postponedTextStrong)
                        .s12
                        .regular
                        .tabular,
                  ),
                ],
              ),
            ),
            8.szW,
            IconWidget(
              icon: AppAssets.svg.chevronLeft,
              color: AppColors.postponedText,
              height: AppSize.sH16,
              width: AppSize.sW16,
            ),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

/// Outlined full-width action (call the branch, start a new day).
class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.icon, required this.label, this.onTap});
  final String icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Container(
        height: AppSize.sH52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppCircular.r15),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconWidget(
              icon: icon,
              color: AppColors.textPrimary,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ),
            8.szW,
            Text(label, style: const TextStyle().setMainTextColor.s14.semiBold),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}
