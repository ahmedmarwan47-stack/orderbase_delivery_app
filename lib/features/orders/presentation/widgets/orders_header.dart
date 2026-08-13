part of '../imports/orders_imports.dart';

/// Header: either the title + date/count + search button + filter chips, or —
/// once the search button is tapped — a real search field with a scope hint.
class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader({required this.vc});
  final OrdersViewController vc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: ValueListenableBuilder<bool>(
        valueListenable: vc.searching,
        builder: (_, searching, _) => searching
            ? _SearchMode(vc: vc)
            : _BrowseMode(vc: vc),
      ).paddingOnlyDirectional(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
    );
  }
}

/// Default header: title, subtitle, the (now real) search button, filter chips.
class _BrowseMode extends StatelessWidget {
  const _BrowseMode({required this.vc});
  final OrdersViewController vc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.queueTitle.tr(),
                  style: const TextStyle().setMainTextColor.s24.extraBold,
                ),
                4.szH,
                Text(
                  LocaleKeys.ordersSubtitle.tr(),
                  style: const TextStyle().setSecondaryColor.s14.regular,
                ),
              ],
            ),
            _SearchButton(onTap: vc.openSearch),
          ],
        ),
        16.szH,
        _OrdersFilterChips(vc: vc),
      ],
    );
  }
}

/// Search header: back button + real search field + scope hint.
class _SearchMode extends StatelessWidget {
  const _SearchMode({required this.vc});
  final OrdersViewController vc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _SearchButton(
              icon: AppAssets.svg.chevronRight,
              label: LocaleKeys.a11yBack.tr(),
              onTap: vc.closeSearch,
            ),
            12.szW,
            Expanded(child: _OrdersSearchField(vc: vc)),
          ],
        ),
        12.szH,
        Text(
          LocaleKeys.searchScope.tr(),
          style: const TextStyle().setHintColor.s12.regular.withHeight(1.7),
        ),
      ],
    );
  }
}

/// Muted square icon tile — the search affordance (and, in search mode, the
/// back button). A 44pt tap area wraps the 44pt visual so it's reliably hit.
class _SearchButton extends StatelessWidget {
  const _SearchButton({this.onTap, this.icon, this.label});

  final VoidCallback? onTap;
  final String? icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        width: AppSize.sW44,
        height: AppSize.sH44,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppCircular.r12),
        ),
        child: Center(
          child: IconWidget(
            icon: icon ?? AppAssets.svg.search,
            color: AppColors.textPrimary,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
        ),
      ).onClick(onTap: onTap),
    );
  }
}

/// Real search field (never a fake Container+Text): autofocuses on open, filters
/// live via [OrdersViewController.onSearchChanged], with an inline clear button.
class _OrdersSearchField extends StatelessWidget {
  const _OrdersSearchField({required this.vc});
  final OrdersViewController vc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH44,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(color: AppColors.inkFill, width: 2),
      ),
      child: Row(
        children: [
          IconWidget(
            icon: AppAssets.svg.search,
            color: AppColors.textSecondary,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
          8.szW,
          Expanded(
            child: TextField(
              controller: vc.searchController,
              autofocus: true,
              onChanged: vc.onSearchChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.brand,
              style: const TextStyle().setMainTextColor.s16.bold,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: LocaleKeys.searchHint.tr(),
                hintStyle: const TextStyle()
                    .setColor(AppColors.chipCountMuted)
                    .s16
                    .bold,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: vc.searchController,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : _ClearChip(onTap: vc.clearSearch).paddingStart(AppPadding.pW8),
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW12),
    );
  }
}

/// Small round clear button inside the search field.
class _ClearChip extends StatelessWidget {
  const _ClearChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.a11yClearSearch.tr(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Center(
          child: Container(
            width: AppSize.sW24,
            height: AppSize.sH24,
            decoration: const BoxDecoration(
              color: AppColors.sheetGrabber,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.x,
                color: AppColors.textTertiary,
                height: AppSize.sH14,
                width: AppSize.sW14,
              ),
            ),
          ),
        ),
      ).onClick(onTap: onTap),
    );
  }
}
