part of '../imports/settlement_imports.dart';

/// State A — OPEN ("تسوية نهاية اليوم"): white header + scrolling paper body
/// (dark cash card, today's collections, locked note, settle CTA) + bottom nav.
class _SettlementOpenView extends StatelessWidget {
  const _SettlementOpenView({required this.vc});
  final SettlementController vc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _SettlementHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: AppPadding.pH20,
                  bottom: AppPadding.pH24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CashInHandCard(vc: vc),
                    20.szH,
                    _CollectionsSection(data: vc.data),
                    16.szH,
                    const _LockedNote(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White header: back link, title + subtitle, and the amber "not settled" pill.
class _SettlementHeader extends StatelessWidget {
  const _SettlementHeader();

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
            mainAxisSize: MainAxisSize.min,
            children: [
              IconWidget(
                icon: AppAssets.svg.chevronRight,
                color: AppColors.textPrimary,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
              4.szW,
              Text(
                LocaleKeys.settlementBack.tr(),
                style: const TextStyle().setMainTextColor.s14.semiBold,
              ),
            ],
          ).onClick(onTap: () => Navigator.of(context).maybePop()),
          12.szH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.settlementTitle.tr(),
                      style: const TextStyle().setMainTextColor.s24.extraBold,
                    ),
                    4.szH,
                    Text(
                      LocaleKeys.settlementSubtitle.tr(),
                      style: const TextStyle().setSecondaryColor.s14.regular,
                    ),
                  ],
                ),
              ),
              12.szW,
              const _NotSettledPill(),
            ],
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
}

/// Amber "غير مُسوّاة" (not settled) status pill with a leading amber dot.
class _NotSettledPill extends StatelessWidget {
  const _NotSettledPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroCodPillBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.w, // 7px status dot — no matching AppSize token
            height: 7.h,
            decoration: const BoxDecoration(
              color: AppColors.postponedText,
              shape: BoxShape.circle,
            ),
          ),
          6.szW,
          Text(
            LocaleKeys.settlementNotSettled.tr(),
            style: const TextStyle().setColor(AppColors.postponedText).s12.bold,
          ),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

