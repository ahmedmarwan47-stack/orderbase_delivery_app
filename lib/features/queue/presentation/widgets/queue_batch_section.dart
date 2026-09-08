part of '../imports/queue_imports.dart';

/// The Orders tab's browse list: the day as batch sections.
///
/// It took the batches page as its skeleton — a courier can be holding several
/// batches at once, and a batch stays visibly one thing rather than dissolving
/// into a flat list — and the queue's filters as its head. Batches waiting at
/// the branch come first, since they need an action; the ones in hand follow,
/// newest first; a completed batch folds itself away.
class _QueueBatchList extends StatelessWidget {
  const _QueueBatchList({required this.groups, required this.vc});
  final List<QueueBatchGroup> groups;
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    // A filter is narrowing the list: the courier has already said what they
    // want to see, so the rows should not be a tap away.
    final filtering = vc.filter.value != QueueFilter.all;
    // One card per batch, 12 apart. A batch carries its own state and its own
    // confirm button, so a shared sheet blurred where one ended and the next
    // began.
    //
    // Plain content, not a scrollable: the page is one CustomScrollView now,
    // and a day is three batches deep, so there is nothing here to lazily
    // build — only a nested scroll to avoid.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, group) in groups.indexed) ...[
          if (i > 0) 12.szH,
          _QueueBatchSection(
            // The filter is part of the key: changing it rebuilds the section
            // so the expansion below is re-evaluated instead of keeping the
            // state the courier had before they filtered.
            key: ValueKey('${group.batch.id}-$filtering'),
            group: group,
            vc: vc,
            // Closed by default: the unfiltered list answers "what rounds do I
            // have" first, and the courier opens the one they want. Under a
            // filter that question is already answered — they asked for these
            // specific orders — so the batch opens on what is left.
            initiallyExpanded: filtering,
          ),
        ],
      ],
    ).paddingOnlyDirectional(
      start: AppPadding.pW20,
      end: AppPadding.pW20,
      top: AppPadding.pH4,
      bottom: AppPadding.pH20,
    );
  }
}

/// One batch as a collapsible **card**: its ID and state, a line sizing it up
/// (orders · remaining · cash · km · return time), then its orders as flat
/// rows. A batch still at the branch closes with its own carry button, so
/// carrying happens where the batch is. Each batch is its own card, and every
/// one arrives closed.
class _QueueBatchSection extends StatefulWidget {
  const _QueueBatchSection({
    super.key,
    required this.group,
    required this.vc,
    this.initiallyExpanded = true,
  });

  final QueueBatchGroup group;
  final QueueViewController vc;
  final bool initiallyExpanded;

  @override
  State<_QueueBatchSection> createState() => _QueueBatchSectionState();
}

class _QueueBatchSectionState extends State<_QueueBatchSection> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    AppHaptics.tick();
    setState(() => _open = !_open);
  }

  Future<void> _carry() async {
    final ok = await showCarryBatchSheet(context, batch: widget.group.batch);
    if (ok != true || !mounted) return;
    AppHaptics.confirm();
    widget.vc.carryBatch(widget.group.batch.id);
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    final rows = [...g.rows]..sort((a, b) => a.num.compareTo(b.num));
    final reduced = AppMotion.reduced(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
        boxShadow: AppShadows.card,
      ),
      // Clips the collapsing body to the rounded corners.
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _QueueBatchHeader(group: g, open: _open, onTap: _toggle),
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
                  for (final order in rows)
                    _QueueBatchRow(
                      order: order,
                      pending: g.pending,
                      last: order == rows.last && !g.pending,
                      onTap: () => widget.vc.openOrder(context, order),
                    ),
                  if (g.pending)
                    _CarryBatchButton(count: g.batch.count, onTap: _carry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The batch's own row: ID + state pill on one line, the sizing line under it,
/// the disclosure chevron at the end.
class _QueueBatchHeader extends StatelessWidget {
  const _QueueBatchHeader({
    required this.group,
    required this.open,
    required this.onTap,
  });

  final QueueBatchGroup group;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final b = group.batch;
    final String meta;
    if (group.pending) {
      meta = LocaleKeys.queueBatchMetaPending.tr(
        namedArgs: {
          'count': arabicDigits(b.count),
          'cash': formatThousands(b.codTotal),
          'km': formatKmArabic(b.routeKm),
        },
      );
    } else if (group.complete) {
      meta = LocaleKeys.queueBatchMetaComplete.tr(
        namedArgs: {'count': arabicDigits(b.count)},
      );
    } else {
      meta = LocaleKeys.queueBatchMetaCarried.tr(
        namedArgs: {
          'count': arabicDigits(b.count),
          'left': arabicDigits(group.remaining),
          'km': formatKmArabic(b.routeKm),
          'time': formatClockArabic(shift.returnEtaOf(b)),
        },
      );
    }
    return Semantics(
      button: true,
      expanded: open,
      label: b.id,
      child:
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          b.id,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle()
                              .setMainTextColor
                              .s14
                              .bold
                              .tabular,
                        ),
                        8.szW,
                        _BatchStatePill(group: group),
                      ],
                    ),
                    4.szH,
                    Text(
                      meta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle()
                          .setSecondaryColor
                          .s12
                          .regular
                          .tabular,
                    ),
                  ],
                ),
              ),
              8.szW,
              AnimatedRotation(
                // Points inward while closed, down while open.
                turns: open ? -0.25 : 0,
                duration: AppMotion.reduced(context)
                    ? Duration.zero
                    : AppMotion.fill,
                curve: AppMotion.ease,
                child: IconWidget(
                  icon: AppAssets.svg.chevronLeft,
                  color: AppColors.textSecondary,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
              ),
            ],
          ).paddingSymmetric(
            horizontal: AppPadding.pW16,
            vertical: AppPadding.pH12,
          ),
    ).onClick(onTap: onTap);
  }
}

/// «في الفرع» (amber — needs carrying) · «معك» · «مكتملة».
class _BatchStatePill extends StatelessWidget {
  const _BatchStatePill({required this.group});
  final QueueBatchGroup group;

  @override
  Widget build(BuildContext context) {
    final (String text, Color bg, Color fg) = group.pending
        ? (
            LocaleKeys.queueBatchAtBranch.tr(),
            AppColors.heroCodPillBg,
            AppColors.postponedText,
          )
        : group.complete
        ? (
            LocaleKeys.queueBatchComplete.tr(),
            AppColors.surfaceMuted,
            AppColors.textSecondary,
          )
        : (
            LocaleKeys.queueBatchInHand.tr(),
            AppColors.transitPillBg,
            AppColors.transitBg,
          );
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r7),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW8,
        vertical: AppPadding.pH2,
      ),
      child: Text(text, style: const TextStyle().setColor(fg).s12.semiBold),
    );
  }
}

/// The ink confirm inside a waiting batch — «تأكيد استلام الجولة (٣)».
class _CarryBatchButton extends StatelessWidget {
  const _CarryBatchButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child:
          Container(
            height: AppSize.sH48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(AppCircular.r14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.check,
                  color: AppColors.surface,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.queueCarryBatch.tr(
                    namedArgs: {'count': arabicDigits(count)},
                  ),
                  style: const TextStyle().setWhite.s14.semiBold,
                ),
              ],
            ),
          ).paddingOnlyDirectional(
            start: AppPadding.pW16,
            end: AppPadding.pW16,
            top: AppPadding.pH12,
            bottom: AppPadding.pH16,
          ),
    ).onClick(onTap: onTap);
  }
}
