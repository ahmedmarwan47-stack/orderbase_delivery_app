part of '../imports/home_imports.dart';

/// «فرع مدينة نصر» — the branch the courier is assigned to today.
///
/// It used to lead the app header. The header is a page title now, so the one
/// fact it carried that no page repeats came down here, directly above the
/// day's numbers: the branch is where those numbers came from and where the
/// cash goes back.
class _HomeBranchLine extends StatelessWidget {
  const _HomeBranchLine({required this.branch});

  final String branch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconWidget(
          icon: AppAssets.svg.store,
          color: AppColors.textSecondary,
          height: AppSize.sH18,
          width: AppSize.sW18,
        ),
        8.szW,
        Expanded(
          child: Text(
            branch,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle().setMainTextColor.s16.semiBold,
          ),
        ),
      ],
    );
  }
}
