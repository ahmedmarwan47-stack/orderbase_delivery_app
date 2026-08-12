part of '../imports/failure_states_imports.dart';

/// Body of the returns list (1g): header + filter chips, the dark returns
/// banner, the active order cards, and the bottom nav.
class _ReturnsListBody extends StatelessWidget {
  const _ReturnsListBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ReturnsHeader(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.pW20,
              vertical: AppPadding.pH16,
            ),
            children: [
              const _ReturnsBanner(),
              12.szH,
              _OrderMiniCard(
                icon: FailureIcons.nav,
                tileBg: AppColors.transitPillBg,
                tileIconColor: AppColors.transitBg,
                orderNum: '#89290',
                pill: _StatusPill(
                  label: LocaleKeys.failureStatusInTransit.tr(),
                  bg: AppColors.transitPillBg,
                  fg: AppColors.transitBg,
                ),
                meta: LocaleKeys.failureSampleMetaSara.tr(),
              ),
              12.szH,
              _OrderMiniCard(
                icon: FailureIcons.clock,
                tileBg: AppColors.heroCodPillBg,
                tileIconColor: AppColors.postponedText,
                orderNum: '#89283',
                pill: _StatusPill(
                  label: LocaleKeys.failureSampleMetaPostponed.tr(),
                  bg: AppColors.heroCodPillBg,
                  fg: AppColors.postponedText,
                ),
                meta: LocaleKeys.failureSampleMetaCorrected.tr(),
              ),
              12.szH,
              _OrderMiniCard(
                icon: FailureIcons.wallet,
                tileBg: AppColors.surfaceMuted,
                tileIconColor: AppColors.textTertiary,
                orderNum: '#89285',
                pill: _StatusPill(
                  label: LocaleKeys.failureStatusDelivered.tr(),
                  bg: AppColors.deliveredBg,
                  fg: AppColors.deliveredText,
                ),
                meta: LocaleKeys.failureSampleMetaMona.tr(),
              ),
            ],
          ),
        ),
        const _ReturnsBottomNav(),
      ],
    );
  }
}

class _ReturnsHeader extends StatelessWidget {
  const _ReturnsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LocaleKeys.failureOrders.tr(),
                  style: const TextStyle().setMainTextColor.s20.extraBold),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppCircular.r8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW12,
                  vertical: AppPadding.pH4,
                ),
                child: Text(LocaleKeys.failureActiveCount.tr(),
                    style: const TextStyle().setSecondaryColor.s12.bold),
              ),
            ],
          ),
          12.szH,
          Row(
            children: [
              _FilterChip(label: LocaleKeys.failureFilterAll.tr(), selected: true),
              8.szW,
              _FilterChip(label: LocaleKeys.failureStatusInTransit.tr()),
              8.szW,
              _FilterChip(label: LocaleKeys.failureFilterFailed.tr()),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selected ? AppColors.inkFill : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH8,
      ),
      child: Text(
        label,
        style: const TextStyle()
            .setColor(selected ? AppColors.surface : AppColors.textTertiary)
            .s12
            .bold,
      ),
    );
  }
}

class _ReturnsBanner extends StatelessWidget {
  const _ReturnsBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconWidget(
                icon: FailureIcons.box,
                color: AppColors.surface,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
              12.szW,
              Expanded(
                child: Text(LocaleKeys.failureReturnsToBranch.tr(),
                    style: const TextStyle().setWhite.s14.bold),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppCircular.r8),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.pW8,
                  vertical: AppPadding.pH4,
                ),
                child: Text(LocaleKeys.failurePiecesCount3.tr(),
                    style: const TextStyle().setMainTextColor.s12.bold),
              ),
            ],
          ),
          12.szH,
          _ReturnItemRow(
            orderNum: '#89289',
            reason: LocaleKeys.failureReasonNotPresent.tr(),
            pieces: LocaleKeys.failureSamplePiecesLabel.tr(),
          ),
          8.szH,
          _ReturnItemRow(
            orderNum: '#89276',
            reason: LocaleKeys.failureReasonMismatch.tr(),
            pieces: LocaleKeys.failurePieces1.tr(),
          ),
          12.szH,
          _OutlineButton(
            label: LocaleKeys.failureHandReturns.tr(),
            height: AppSize.sH48,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReturnItemRow extends StatelessWidget {
  const _ReturnItemRow({
    required this.orderNum,
    required this.reason,
    required this.pieces,
  });
  final String orderNum;
  final String reason;
  final String pieces;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardRowBg,
        borderRadius: BorderRadius.circular(AppCircular.r12),
      ),
      padding: EdgeInsets.all(AppPadding.pH12),
      child: Row(
        children: [
          Text(
            orderNum,
            textDirection: TextDirection.ltr,
            style: const TextStyle().setWhite.s14.extraBold,
          ),
          12.szW,
          Expanded(
            child: Text(
              reason,
              style: const TextStyle().setColor(AppColors.mutedOnDark).s12.regular,
            ),
          ),
          Text(pieces, style: const TextStyle().setWhite.s12.bold),
        ],
      ),
    );
  }
}

class _OrderMiniCard extends StatelessWidget {
  const _OrderMiniCard({
    required this.icon,
    required this.tileBg,
    required this.tileIconColor,
    required this.orderNum,
    required this.pill,
    required this.meta,
  });
  final String icon;
  final Color tileBg;
  final Color tileIconColor;
  final String orderNum;
  final Widget pill;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Row(
        children: [
          Container(
            width: AppSize.sW40,
            height: AppSize.sH40,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: icon,
                color: tileIconColor,
                height: AppSize.sH20,
                width: AppSize.sW20,
              ),
            ),
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      orderNum,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s16.extraBold,
                    ),
                    8.szW,
                    pill,
                  ],
                ),
                4.szH,
                Text(meta, style: const TextStyle().setSecondaryColor.s12.regular),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The mockup's 1g bottom nav differs from the shared [BottomNav] (it shows
/// التحصيل / الحساب instead of notifications / more), so it's rendered locally
/// here to stay faithful. Reconcile with the app's real nav at integration.
class _ReturnsBottomNav extends StatelessWidget {
  const _ReturnsBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: AppPadding.pW16,
              right: AppPadding.pW16,
              top: AppPadding.pH12,
              bottom: AppPadding.pH8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: FailureIcons.home, label: LocaleKeys.failureNavHome.tr()),
                _NavItem(
                    icon: FailureIcons.orders,
                    label: LocaleKeys.failureOrders.tr(),
                    active: true),
                _NavItem(icon: FailureIcons.wallet, label: LocaleKeys.failureNavCollection.tr()),
                _NavItem(icon: FailureIcons.note, label: LocaleKeys.failureNavAccount.tr()),
              ],
            ),
          ),
          // Home-indicator pill.
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.pH8),
            child: Container(
              width: 135.w, // home-indicator pill — no token
              height: AppSize.sH4,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppCircular.r3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, this.active = false});
  final String icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.textPrimary : AppColors.chipCountMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconWidget(icon: icon, color: color, height: AppSize.sH22, width: AppSize.sW22),
        4.szH,
        Text(
          label,
          style: active
              ? const TextStyle().setColor(color).s12.bold
              : const TextStyle().setColor(color).s12.semiBold,
        ),
      ],
    );
  }
}
