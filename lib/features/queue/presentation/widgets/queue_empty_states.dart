part of '../imports/queue_imports.dart';

/// Queue cleared (1d) — no active orders, with the postponed hand-off and the
/// end-of-day settlement entry.
class _QueueClearState extends StatelessWidget {
  const _QueueClearState({required this.vc});
  final QueueViewController vc;

  @override
  Widget build(BuildContext context) {
    final postponed = vc.postponed;
    return SingleChildScrollView(
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _EmptyBadge(
                  bg: AppColors.deliveredBg,
                  icon: AppAssets.svg.check,
                  iconColor: AppColors.deliveredText,
                ),
              ),
              24.szH,
              Text(
                LocaleKeys.queueClearTitle.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setMainTextColor.s20.bold,
              ),
              8.szH,
              Text(
                LocaleKeys.queueClearDesc.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setSecondaryColor.s14.regular
                    .withHeight(1.5),
              ),
              24.szH,
              if (postponed.isNotEmpty)
                _PostponedHandoffCard(
                  postponed: postponed,
                  onView: vc.openPostponed,
                ),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW24,
            end: AppPadding.pW24,
            top: AppPadding.pH56,
            bottom: AppPadding.pH24,
          ),
    );
  }
}

/// Amber card summarising postponed orders + "view postponed" action.
class _PostponedHandoffCard extends StatelessWidget {
  const _PostponedHandoffCard({required this.postponed, required this.onView});
  final List<Order> postponed;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(AppCircular.r20),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconWidget(
                    icon: AppAssets.svg.clock,
                    color: AppColors.postponedText,
                    height: AppSize.sH18,
                    width: AppSize.sW18,
                  ),
                  8.szW,
                  Text(
                    LocaleKeys.postponedWithYou.tr(
                      namedArgs: {'count': arabicDigits(postponed.length)},
                    ),
                    style: const TextStyle()
                        .setColor(AppColors.postponedText)
                        .s14
                        .semiBold,
                  ),
                ],
              ),
              if (postponed.first.returns != null)
                Text(
                  LocaleKeys.nearestReturns.tr(
                    namedArgs: {'time': postponed.first.returns!},
                  ),
                  style: const TextStyle()
                      .setColor(AppColors.postponedTextStrong)
                      .s12
                      .semiBold,
                ),
            ],
          ),
          12.szH,
          Text(
            LocaleKeys.postponedNote.tr(),
            style: const TextStyle()
                .setColor(AppColors.postponedTextStrong)
                .s12
                .regular
                .withHeight(1.5),
          ),
          12.szH,
          _OutlinedPillButton(
            labelKey: LocaleKeys.viewPostponed,
            labelColor: AppColors.postponedText,
            borderColor: AppColors.postponedBorderStrong,
            trailing: AppAssets.svg.chevronRight,
            onTap: onView,
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// Empty search prompt (1a, before typing) — a designed empty state (badge +
/// prompt + scope card) rather than a bare line of text.
class _QueueSearchPrompt extends StatelessWidget {
  const _QueueSearchPrompt();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _EmptyBadge(
                  bg: AppColors.surfaceSubtle,
                  icon: AppAssets.svg.search,
                  iconColor: AppColors.chipCountMuted,
                ),
              ),
              24.szH,
              Text(
                LocaleKeys.searchPrompt.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setMainTextColor.s20.bold,
              ),
              24.szH,
              _ScopeCard(),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW32,
            end: AppPadding.pW32,
            top: AppPadding.pH64,
            bottom: AppPadding.pH24,
          ),
    );
  }
}

/// No search results (1c) — states the search scope so a postponed order doesn't
/// read as "lost".
class _QueueNoResults extends StatelessWidget {
  const _QueueNoResults({required this.vc, required this.query});
  final QueueViewController vc;
  final String query;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: _EmptyBadge(
                  bg: AppColors.surfaceSubtle,
                  icon: AppAssets.svg.search,
                  iconColor: AppColors.chipCountMuted,
                ),
              ),
              24.szH,
              Text(
                LocaleKeys.noResultsTitle.tr(
                  namedArgs: {'query': query.trim()},
                ),
                textAlign: TextAlign.center,
                style: const TextStyle().setMainTextColor.s20.bold,
              ),
              8.szH,
              Text(
                LocaleKeys.noResultsDesc.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setSecondaryColor.s14.regular
                    .withHeight(1.5),
              ),
              24.szH,
              Center(child: _ClearSearchButton(onTap: vc.clearSearch)),
              24.szH,
              _ScopeCard(),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW32,
            end: AppPadding.pW32,
            top: AppPadding.pH64,
            bottom: AppPadding.pH24,
          ),
    );
  }
}

/// Dark pill "clear search" button.
class _ClearSearchButton extends StatelessWidget {
  const _ClearSearchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: AppColors.inkFill,
        borderRadius: BorderRadius.circular(AppCircular.r14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.x,
            color: AppColors.surface,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Text(
            LocaleKeys.clearSearch.tr(),
            style: const TextStyle().setWhite.s14.semiBold,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW20),
    ).onClick(onTap: onTap);
  }
}

/// White card explaining what the search covers.
class _ScopeCard extends StatelessWidget {
  const _ScopeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.searchScopeTitle.tr(),
            style: const TextStyle().setMainTextColor.s12.semiBold,
          ),
          8.szH,
          Text(
            LocaleKeys.searchScopeDesc.tr(),
            style: const TextStyle().setSecondaryColor.s12.regular.withHeight(
              1.5,
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// 72×72 rounded badge behind an empty-state icon.
class _EmptyBadge extends StatelessWidget {
  const _EmptyBadge({
    required this.bg,
    required this.icon,
    required this.iconColor,
  });
  final Color bg;
  final String icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sH72,
      height: AppSize.sH72,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r24),
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: iconColor,
          height: AppSize.sH32,
          width: AppSize.sH32,
        ),
      ),
    );
  }
}

/// White/outline pill button with an optional trailing icon (the
/// view-postponed action).
class _OutlinedPillButton extends StatelessWidget {
  const _OutlinedPillButton({
    required this.labelKey,
    required this.labelColor,
    required this.borderColor,
    this.trailing,
    this.onTap,
  });

  final String labelKey;
  final Color labelColor;
  final Color borderColor;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelKey.tr(),
            style: const TextStyle().setColor(labelColor).s14.semiBold,
          ),
          if (trailing != null) ...[
            8.szW,
            IconWidget(
              icon: trailing!,
              color: labelColor,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ),
          ],
        ],
      ),
    ).onClick(onTap: onTap);
  }
}
