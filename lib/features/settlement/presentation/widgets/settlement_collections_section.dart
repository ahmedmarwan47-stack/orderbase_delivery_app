part of '../imports/settlement_imports.dart';

/// «دفعات اليوم» — the day batch by batch. Each batch is a collapsible
/// section headed by its ID and what it produced (cash · cash orders ·
/// returns); open it for the cash lines (collected vs order value, wallet
/// change) and the parcels it sends back. A batch still at the branch is one
/// muted line, so the day still accounts for it. Replaced the flat collections
/// card: the cashier settles the day, but reconciles it batch by batch.
class _BatchesSection extends StatelessWidget {
  const _BatchesSection({required this.data});
  final SettlementData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.settlementBatchesTitle.tr(),
              style: const TextStyle().setMainTextColor.s16.semiBold,
            ),
            Text(
              data.isSettled
                  ? LocaleKeys.settlementClosed.tr()
                  : LocaleKeys.settlementCollectionsHint.tr(),
              style: const TextStyle().setHintColor.s12.regular,
            ),
          ],
        ),
        12.szH,
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCircular.r16),
            border: Border.all(color: AppColors.borderCard),
            boxShadow: AppShadows.card,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < data.batches.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.surfaceSubtle,
                  ),
                _SettlementBatchSection(
                  key: ValueKey(data.batches[i].id),
                  batch: data.batches[i],
                  // The first batch with something in it opens; the rest fold.
                  initiallyExpanded: i == 0,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One batch: header row (ID · summary · chevron), then its cash lines and
/// returns when open.
class _SettlementBatchSection extends StatefulWidget {
  const _SettlementBatchSection({
    super.key,
    required this.batch,
    this.initiallyExpanded = false,
  });
  final SettlementBatch batch;
  final bool initiallyExpanded;

  @override
  State<_SettlementBatchSection> createState() =>
      _SettlementBatchSectionState();
}

class _SettlementBatchSectionState extends State<_SettlementBatchSection> {
  late bool _open = widget.initiallyExpanded;

  bool get _hasBody =>
      widget.batch.lines.isNotEmpty || widget.batch.returns.isNotEmpty;

  void _toggle() {
    if (!_hasBody) return;
    AppHaptics.tick();
    setState(() => _open = !_open);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.batch;
    final reduced = AppMotion.reduced(context);
    final String meta;
    if (b.pending) {
      meta = LocaleKeys.settlementBatchPending.tr();
    } else if (!_hasBody) {
      meta = LocaleKeys.settlementBatchNoCash.tr(
        namedArgs: {'count': arabicDigits(b.orderCount)},
      );
    } else {
      meta = [
        if (b.lines.isNotEmpty) ...[
          LocaleKeys.settlementBatchCash.tr(
            namedArgs: {'cash': formatThousands(b.cashTotal)},
          ),
          LocaleKeys.settlementBatchCashOrders.tr(
            namedArgs: {'count': arabicDigits(b.lines.length)},
          ),
        ],
        if (b.returns.isNotEmpty)
          LocaleKeys.settlementBatchReturns.tr(
            namedArgs: {'count': arabicDigits(b.returns.length)},
          ),
      ].join(' · ');
    }
    final muted = b.pending || !_hasBody;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: _hasBody,
          expanded: _hasBody ? _open : null,
          label: b.id,
          child:
              Row(
                children: [
                  Text(
                    b.id,
                    textDirection: TextDirection.ltr,
                    style:
                        (muted
                                ? const TextStyle().setSecondaryColor
                                : const TextStyle().setMainTextColor)
                            .s14
                            .bold
                            .tabular,
                  ),
                  if (b.pending) ...[
                    8.szW,
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.heroCodPillBg,
                        borderRadius: BorderRadius.circular(AppCircular.r7),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.pW8,
                        vertical: AppPadding.pH2,
                      ),
                      child: Text(
                        LocaleKeys.queueBatchAtBranch.tr(),
                        style: const TextStyle()
                            .setColor(AppColors.postponedText)
                            .s10
                            .semiBold,
                      ),
                    ),
                  ],
                  12.szW,
                  Expanded(
                    child: Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle()
                          .setSecondaryColor
                          .s12
                          .regular
                          .tabular,
                    ),
                  ),
                  if (_hasBody) ...[
                    8.szW,
                    AnimatedRotation(
                      turns: _open ? -0.25 : 0,
                      duration: reduced ? Duration.zero : AppMotion.fill,
                      curve: AppMotion.ease,
                      child: IconWidget(
                        icon: AppAssets.svg.chevronLeft,
                        color: AppColors.textSecondary,
                        height: AppSize.sH16,
                        width: AppSize.sW16,
                      ),
                    ),
                  ],
                ],
              ).paddingSymmetric(
                horizontal: AppPadding.pW16,
                vertical: AppPadding.pH12,
              ),
        ).onClick(onTap: _hasBody ? _toggle : null),
        if (_hasBody)
          ClipRect(
            child: AnimatedAlign(
              alignment: AlignmentDirectional.topCenter,
              heightFactor: _open ? 1 : 0,
              duration: reduced ? Duration.zero : AppMotion.fill,
              curve: AppMotion.ease,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final line in b.lines) _CollectionRow(line: line),
                  for (final r in b.returns) _ReturnRow(line: r),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// One cash order inside a batch.
class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.line});
  final SettlementLine line;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceSubtle)),
      ),
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW24,
        end: AppPadding.pW16,
        top: AppPadding.pH12,
        bottom: AppPadding.pH12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      line.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s14.bold,
                    ),
                    8.szW,
                    Flexible(
                      child: Text(
                        line.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle().setMainTextColor.s14.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
              12.szW,
              Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formatThousands(line.paid),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle().setMainTextColor.s16.bold.tabular,
                  ),
                  4.szW,
                  Text(
                    LocaleKeys.settlementCurrency.tr(),
                    style: const TextStyle().setSecondaryColor.s12.semiBold,
                  ),
                ],
              ),
            ],
          ),
          8.szH,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.settlementOrderValue.tr(
                  namedArgs: {'value': formatThousands(line.order)},
                ),
                style: const TextStyle().setHintColor.s12.regular,
              ),
              if (line.hasWallet) _WalletPill(amount: line.wallet),
            ],
          ),
        ],
      ),
    );
  }
}

/// One parcel going back, inside its batch: number + name, the reason, and
/// the piece count the branch checks against.
class _ReturnRow extends StatelessWidget {
  const _ReturnRow({required this.line});
  final SettlementReturn line;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceSubtle)),
      ),
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW24,
        end: AppPadding.pW16,
        top: AppPadding.pH12,
        bottom: AppPadding.pH12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      line.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s14.semiBold,
                    ),
                    8.szW,
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.failedBg,
                        borderRadius: BorderRadius.circular(AppCircular.r7),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.pW8,
                        vertical: AppPadding.pH2,
                      ),
                      child: Text(
                        LocaleKeys.settlementReturnPill.tr(),
                        style: const TextStyle()
                            .setColor(AppColors.failedText)
                            .s10
                            .semiBold,
                      ),
                    ),
                    8.szW,
                    Flexible(
                      child: Text(
                        line.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle().setSecondaryColor.s12.regular,
                      ),
                    ),
                  ],
                ),
                4.szH,
                Text(
                  line.reason,
                  style: const TextStyle().setHintColor.s12.regular,
                ),
              ],
            ),
          ),
          8.szW,
          Text(
            _piecesLabel(line.pieces),
            style: const TextStyle().setSecondaryColor.s12.semiBold,
          ),
        ],
      ),
    );
  }
}

/// Small amber pill: "فكة {change} جم" with a wallet glyph — shown on a line
/// whose collected cash exceeded the order value.
class _WalletPill extends StatelessWidget {
  const _WalletPill({required this.amount});
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.wallet,
            color: AppColors.postponedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          6.szW,
          Text(
            LocaleKeys.settlementWalletChange.tr(
              namedArgs: {'amount': formatThousands(amount)},
            ),
            style: const TextStyle()
                .setColor(AppColors.postponedText)
                .s12
                .semiBold,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}
