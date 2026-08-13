part of '../imports/home_imports.dart';

/// The next-stop hero card — progress, a map strip, the *current* order's
/// details, and the primary "view order" + call/chat actions. Everything is
/// driven by [ShiftController.nextStop]; when the route is finished it collapses
/// to a "route complete" state.
class _HomeNextStopCard extends StatelessWidget {
  const _HomeNextStopCard({this.onViewOrder});

  final VoidCallback? onViewOrder;

  @override
  Widget build(BuildContext context) {
    final shift = ShiftController.instance;
    final order = shift.nextStop;
    if (order == null) return const _HomeRouteCompleteCard();

    final isCod = order.cod != null && !order.prepaid;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r22),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── header: "next stop" + station count ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconWidget(
                    icon: AppAssets.svg.nav,
                    color: AppColors.brand,
                    height: AppSize.sH18,
                    width: AppSize.sW18,
                  ),
                  8.szW,
                  Text(
                    LocaleKeys.homeNextStop.tr(),
                    style: const TextStyle().setMainTextColor.s14.bold,
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.failedBg,
                  borderRadius: BorderRadius.circular(AppCircular.r20),
                ),
                child: Text(
                  LocaleKeys.homeStopCount.tr(namedArgs: {
                    'current': '${shift.currentStopNumber}',
                    'total': '${shift.totalStops}',
                  }),
                  style: const TextStyle()
                      .setColor(AppColors.stopCountText)
                      .s12
                      .semiBold,
                ).paddingSymmetric(
                  horizontal: AppPadding.pW12,
                  vertical: AppPadding.pH4,
                ),
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH12,
          ),
          // ── progress segments (one per route stop) ──
          Row(
            spacing: AppSize.sW8,
            children: [
              for (final s in shift.routeStops)
                _HomeProgressSeg(_segColor(s, order)),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
          // ── map strip ──
          MapView(height: AppSize.sH96, showHairlines: true),
          // ── order info ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.homeOrderNo.tr(
                      namedArgs: {'num': order.num.replaceAll('#', '')},
                    ),
                    style: const TextStyle().setMainTextColor.s16.bold.tabular,
                  ),
                  _PayPill(isCod: isCod),
                ],
              ),
              8.szH,
              Text(
                order.name,
                style: const TextStyle().setMainTextColor.s18.bold,
              ),
              8.szH,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconWidget(
                    icon: AppAssets.svg.pin,
                    color: AppColors.brand,
                    height: AppSize.sH16,
                    width: AppSize.sW16,
                  ),
                  8.szW,
                  Expanded(
                    child: Text(
                      order.fullAddress,
                      style: const TextStyle()
                          .setTertiaryColor
                          .s14
                          .regular
                          .withHeight(1.5),
                    ),
                  ),
                ],
              ),
              if (order.due != null || order.dist != null) ...[
                8.szH,
                Row(
                  children: [
                    if (order.due != null) ...[
                      IconWidget(
                        icon: AppAssets.svg.clock,
                        color: AppColors.textTertiary,
                        height: 15.h, // mockup glyph 15px (off the 4px grid)
                        width: 15.w,
                      ),
                      4.szW,
                      Text(
                        LocaleKeys.promisedAt.tr(namedArgs: {'time': order.due!}),
                        style: const TextStyle().setTertiaryColor.s12.regular,
                      ),
                    ],
                    if (order.due != null && order.dist != null) ...[
                      12.szW,
                      Container(
                        width: 3.w, // 3px separator dot (off the 4px grid)
                        height: 3.h,
                        decoration: const BoxDecoration(
                          color: AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      12.szW,
                    ],
                    if (order.dist != null)
                      Text(
                        order.dist!,
                        style: const TextStyle()
                            .setTertiaryColor
                            .s12
                            .regular
                            .tabular,
                      ),
                  ],
                ),
              ],
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH4,
          ),
          // ── actions ──
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: AppSize.sH52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.inkFill,
                      borderRadius: BorderRadius.circular(AppCircular.r15), // radii exempt
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          LocaleKeys.homeViewOrder.tr(),
                          style: const TextStyle().setWhite.s16.bold,
                        ),
                        8.szW,
                        IconWidget(
                          icon: AppAssets.svg.chevronLeft,
                          color: AppColors.surface,
                          height: AppSize.sH18,
                          width: AppSize.sW18,
                        ),
                      ],
                    ),
                  ),
                ).onClick(onTap: onViewOrder),
              ),
              12.szW,
              _HomeSquareIconButton(
                icon: AppAssets.svg.phone,
                iconColor: AppColors.brand,
                size: AppSize.sH52,
                iconSize: 21.h, // mockup glyph 21px (off the 4px grid)
                radius: AppCircular.r15,
                background: AppColors.surface,
                border: AppColors.brand,
                borderWidth: 1.5,
              ),
              12.szW,
              _HomeSquareIconButton(
                icon: AppAssets.svg.chat,
                iconColor: AppColors.greenAccent,
                size: AppSize.sH52,
                iconSize: 21.h,
                radius: AppCircular.r15,
                background: AppColors.deliveredBg,
                border: AppColors.deliveredBorder,
              ),
            ],
          ).paddingOnly(
            left: AppPadding.pW20,
            top: AppPadding.pH16,
            right: AppPadding.pW20,
            bottom: AppPadding.pH16,
          ),
        ],
      ),
    );
  }

  /// Progress-segment colour: delivered → green, failed → red, the current stop
  /// → ink (kept distinct from the failed red so two reds never sit on the same
  /// bar), upcoming stops → the faint track.
  Color _segColor(Order stop, Order current) {
    if (stop.status == OrderStatus.delivered) return AppColors.greenAccent;
    if (stop.status == OrderStatus.failed) return AppColors.failedText;
    if (stop.num == current.num) return AppColors.inkFill;
    return AppColors.borderDefault;
  }
}

/// The COD / prepaid pill in the hero header.
class _PayPill extends StatelessWidget {
  const _PayPill({required this.isCod});
  final bool isCod;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCod ? AppColors.heroCodPillBg : AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Text(
        (isCod ? LocaleKeys.payCod : LocaleKeys.payPrepaid).tr(),
        style: const TextStyle()
            .setColor(isCod ? AppColors.postponedText : AppColors.deliveredText)
            .s12
            .bold,
      ).paddingSymmetric(
        horizontal: AppPadding.pW12,
        vertical: AppPadding.pH4,
      ),
    );
  }
}

/// Shown in place of the hero once every stop on the route is closed.
class _HomeRouteCompleteCard extends StatelessWidget {
  const _HomeRouteCompleteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r22),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.heroCard,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.pW20,
        vertical: AppPadding.pH32,
      ),
      child: Column(
        children: [
          Container(
            width: AppSize.sW64,
            height: AppSize.sH64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.deliveredBg,
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.check,
                color: AppColors.greenAccent,
                height: AppSize.sH32,
                width: AppSize.sH32,
              ),
            ),
          ),
          16.szH,
          Text(
            LocaleKeys.homeRouteCompleteTitle.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle().setMainTextColor.s18.extraBold,
          ),
          8.szH,
          Text(
            LocaleKeys.homeRouteCompleteSub.tr(),
            textAlign: TextAlign.center,
            style: const TextStyle()
                .setSecondaryColor
                .s14
                .regular
                .withHeight(1.6),
          ),
        ],
      ),
    );
  }
}
