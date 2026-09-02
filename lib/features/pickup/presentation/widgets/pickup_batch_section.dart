part of '../imports/pickup_imports.dart';

/// One dispatched batch as a **collapsible section**: a header naming the batch
/// and what it holds, then its orders as flat rows.
///
/// The Pickup tab is a view of *batches* — a courier can be holding several at
/// once — so a batch stays visibly one thing rather than dissolving into a flat
/// list where you cannot tell which orders arrived together. It collapses
/// because a batch the courier has already checked is just noise between them
/// and the one they are working through: the header alone (count + cash) is
/// enough to keep it accounted for.
///
/// The section is drawn as list structure, not as a card — no outline, no fill,
/// no rounded box around a box. It sits straight on the page and a hairline is
/// all that closes each row and each section.
class _PickupBatchSection extends StatefulWidget {
  const _PickupBatchSection({
    required this.batch,
    this.initiallyExpanded = true,
    this.last = false,
  });

  final OrderBatch batch;

  /// Whether the section starts open. The first batch does — it is the one the
  /// courier is about to carry.
  final bool initiallyExpanded;

  /// Last section in the list — skips the closing rule.
  final bool last;

  @override
  State<_PickupBatchSection> createState() => _PickupBatchSectionState();
}

class _PickupBatchSectionState extends State<_PickupBatchSection> {
  late bool _open = widget.initiallyExpanded;

  void _toggle() {
    AppHaptics.tick();
    setState(() => _open = !_open);
  }

  @override
  Widget build(BuildContext context) {
    final orders = [...widget.batch.orders]
      ..sort((a, b) => a.num.compareTo(b.num));
    final reduced = AppMotion.reduced(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: widget.last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _PickupBatchHeader(batch: widget.batch, open: _open, onTap: _toggle),
          // Collapse by animating the real height away, so the sections below
          // slide up rather than jump.
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
                  for (final order in orders)
                    _PickupOrderRow(
                      order: orderToFlow(order),
                      last: order == orders.last,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The batch's own row: its name, what it holds, and the disclosure chevron.
class _PickupBatchHeader extends StatelessWidget {
  const _PickupBatchHeader({
    required this.batch,
    required this.open,
    required this.onTap,
  });

  final OrderBatch batch;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cash = formatThousands(batch.codTotal);
    final meta = LocaleKeys.pickupBatchMeta.tr(
      // Counts are Arabic prose, so they take Eastern digits; the cash figure
      // stays Western, like every other money figure in the app.
      namedArgs: {'count': arabicDigits(batch.count), 'cash': cash},
    );
    final at = meta.indexOf(cash);
    final quiet = const TextStyle().setSecondaryColor.s12.regular;
    return Semantics(
      button: true,
      expanded: open,
      label: batch.id,
      child:
          Row(
            children: [
              // The ID as the branch prints it — «B #7877».
              Text(
                batch.id,
                textDirection: TextDirection.ltr,
                style: const TextStyle().setMainTextColor.s14.bold.tabular,
              ),
              12.szW,
              // Only the cash total is picked out — black and a step heavier —
              // so the figure reads at a glance while the words around it stay
              // quiet. Split on the substituted number so it works in either
              // locale without a second string.
              Expanded(
                child: at < 0
                    ? Text(meta, style: quiet)
                    : Text.rich(
                        TextSpan(
                          style: quiet,
                          children: [
                            TextSpan(text: meta.substring(0, at)),
                            TextSpan(
                              text: cash,
                              style: const TextStyle()
                                  .setColor(AppColors.flatBlack)
                                  .s12
                                  .semiBold,
                            ),
                            TextSpan(text: meta.substring(at + cash.length)),
                          ],
                        ),
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
            horizontal: AppPadding.pW20,
            vertical: AppPadding.pH12,
          ),
    ).onClick(onTap: onTap);
  }
}
