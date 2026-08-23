part of '../imports/orders_imports.dart';

/// The three filter chips (all / active / done). Rebuilds on selection via the
/// controller's [OrdersViewController.filter] notifier.
class _OrdersFilterChips extends StatelessWidget {
  const _OrdersFilterChips({required this.vc});
  final OrdersViewController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OrdersFilter>(
      valueListenable: vc.filter,
      builder: (_, selected, _) => Row(
        spacing: AppSize.sW4,
        children: [
          for (final f in OrdersFilter.values)
            _OrdersFilterChip(
              labelKey: vc.filterLabelKey(f),
              count: vc.countFor(f),
              selected: selected == f,
              onTap: () => vc.selectFilter(f),
            ),
        ],
      ),
    );
  }
}

class _OrdersFilterChip extends StatelessWidget {
  const _OrdersFilterChip({
    required this.labelKey,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String labelKey;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH40,
      decoration: BoxDecoration(
        color: selected ? AppColors.inkFill : AppColors.surface,
        borderRadius: BorderRadius.circular(100), // full pill (radii 4px-exempt)
        border: Border.all(
          color: selected ? AppColors.inkFill : AppColors.borderDefault,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelKey.tr(),
            style: const TextStyle()
                .setColor(selected ? AppColors.surface : AppColors.textTertiary)
                .s14
                .semiBold,
          ),
          8.szW,
          Text(
            '$count',
            style: const TextStyle()
                .setColor(
                    selected ? AppColors.surface : AppColors.chipCountMuted)
                .s12
                .semiBold
                .tabular,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW16),
    ).onClick(onTap: onTap);
  }
}
