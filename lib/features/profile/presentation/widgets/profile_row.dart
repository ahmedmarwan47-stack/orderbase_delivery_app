part of '../imports/profile_imports.dart';

/// A group of profile rows drawn as one surface.
class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderHeader),
          bottom: BorderSide(color: AppColors.borderHeader),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// One action row — glyph, label, chevron.
class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
    this.last = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  /// Signing out — the one row that undoes something, so it carries the danger
  /// hue. Status greens/reds stay reserved for delivery outcomes.
  final bool danger;

  final bool last;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppColors.dangerAccent : AppColors.textPrimary;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.itemDivider)),
      ),
      child:
          Row(
            children: [
              IconWidget(
                icon: icon,
                color: fg,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
              16.szW,
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle().setColor(fg).s14.semiBold,
                ),
              ),
              if (!danger)
                IconWidget(
                  icon: AppAssets.svg.chevronLeft,
                  color: AppColors.textSecondary,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
            ],
          ).paddingSymmetric(
            horizontal: AppPadding.pW20,
            vertical: AppPadding.pH16,
          ),
    ).onClick(onTap: onTap);
  }
}
