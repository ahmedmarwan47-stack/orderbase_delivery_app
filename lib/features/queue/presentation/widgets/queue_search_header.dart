part of '../imports/queue_imports.dart';

/// Search header (1a/1c): back button + real search field + scope hint.
class _QueueSearchHeader extends StatelessWidget {
  const _QueueSearchHeader({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SquareIconButton(
                icon: AppAssets.svg.chevronRight,
                onTap: () => _onBack(context),
                size: AppSize.sH40,
                label: LocaleKeys.a11yBack.tr(),
              ),
              12.szW,
              Expanded(child: _SearchField(vc: vc)),
            ],
          ),
          12.szH,
          Text(
            LocaleKeys.searchScope.tr(),
            style: const TextStyle().setHintColor.s12.regular.withHeight(1.7),
          ),
        ],
      ).paddingOnlyDirectional(
        start: AppPadding.pW20,
        end: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
    );
  }

  /// Back/close behaviour: clear the query first if there's anything typed;
  /// once it's empty, leave search. When the screen was opened straight into
  /// search (pushed from Home/Orders) there's no browse mode to return to, so
  /// pop the route; otherwise fall back to the browse header.
  void _onBack(BuildContext context) {
    if (vc.searchController.text.isNotEmpty) {
      vc.clearSearch();
    } else if (vc.startedInSearch) {
      Navigator.of(context).maybePop();
    } else {
      vc.closeSearch();
    }
  }
}

/// Real debounced search field (never a fake Container+Text).
class _SearchField extends StatelessWidget {
  const _SearchField({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r14),
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
                hintStyle:
                    const TextStyle().setColor(AppColors.chipCountMuted).s16.bold,
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
    // 24pt dot visual, but a 44pt tap area so it's reliably hittable.
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
