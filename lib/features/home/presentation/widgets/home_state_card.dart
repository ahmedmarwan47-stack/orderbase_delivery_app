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
/// A batch waiting at the branch adds an amber «دفعة جديدة في انتظارك» row to
/// any of the three, since collecting it is then the next thing to do.
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
          style: const TextStyle().setMainTextColor.s18.bold,
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
    ).paddingSymmetric(
      horizontal: AppPadding.pW20,
      vertical: AppPadding.pH32,
    );
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
            Row(
              children: [
                if (batch != null)
                  Expanded(
                    child: _HomeBatchLine(
                      batch: batch,
                      current: shift.totalStops,
                      total: shift.totalStops,
                      returnEta: eta,
                      routeKm: batch.routeKm,
                      done: true,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            12.szH,
            // The status pill — the one fact the branch and the courier share.
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
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
              ),
            ),
            12.szH,
            Text(
              LocaleKeys.homeReturnTitle.tr(),
              style: const TextStyle().setMainTextColor.s20.bold.withHeight(
                1.3,
              ),
            ),
            4.szH,
            Text(
              '${Courier.merchantName} · ${shift.branchName}',
              style: const TextStyle().setTertiaryColor.s14.regular,
            ),
            4.szH,
            Text(
              LocaleKeys.homeReturnBody.tr(
                namedArgs: {'km': formatKmArabic(OrderBatch.returnLegKm)},
              ),
              style: const TextStyle().setSecondaryColor.s12.regular,
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
              _PendingBatchRow(onTap: onOpenPendingBatch),
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
          style: const TextStyle().setMainTextColor.s18.bold,
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
    ).paddingSymmetric(
      horizontal: AppPadding.pW20,
      vertical: AppPadding.pH32,
    );
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

/// Amber «دفعة جديدة في انتظارك» → the Orders tab.
class _PendingBatchRow extends StatelessWidget {
  const _PendingBatchRow({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pending = ShiftController.instance.pendingBatches;
    final ids = pending.map((b) => b.id).join(' · ');
    return Semantics(
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.postponedBannerBg,
          borderRadius: BorderRadius.circular(AppCircular.r12),
          border: Border.all(color: AppColors.postponedBorder),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW12,
          vertical: AppPadding.pH12,
        ),
        child: Row(
          children: [
            IconWidget(
              icon: AppAssets.svg.box,
              color: AppColors.postponedText,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ),
            8.szW,
            Expanded(
              child: Text(
                '${LocaleKeys.homeNewBatchWaiting.tr()} · $ids',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle()
                    .setColor(AppColors.postponedText)
                    .s12
                    .semiBold,
              ),
            ),
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
