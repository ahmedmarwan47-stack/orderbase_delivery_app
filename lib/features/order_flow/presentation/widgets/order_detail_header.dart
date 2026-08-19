part of '../imports/order_flow_imports.dart';

/// Header — back button, order number + date, a per-order status pill and
/// (for COD orders only) the red COD note. Everything is driven by [order].
/// Transparent at the top; fades in the surface background + hairline bottom
/// border once the detail content scrolls beneath it ([scrolled]).
class _OrderDetailHeader extends StatelessWidget {
  const _OrderDetailHeader({required this.order, this.scrolled = false});

  /// The order being shown; drives the number, date, status pill and COD note.
  final FlowOrder order;

  /// True once the page has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    // Status pill styling + label by order state. `active` keeps the mockup's
    // solid-blue "transit" pill exactly; `done`/`failed` reuse the green/red
    // pale-pill tokens shared with the orders list and result screen.
    final (Color pillBg, Color pillFg, String pillLabel) =
        switch (order.state) {
      FlowOrderState.active => (
          // Light pill (matching the pale delivered/failed pills) instead of the
          // loud solid blue.
          AppColors.transitPillBg,
          AppColors.transitBg,
          LocaleKeys.orderDetailStatusTransit.tr(),
        ),
      FlowOrderState.done => (
          AppColors.deliveredBg,
          AppColors.deliveredText,
          LocaleKeys.orderDetailStatusDone.tr(),
        ),
      FlowOrderState.failed => (
          AppColors.failedBg,
          AppColors.failedText,
          LocaleKeys.orderDetailStatusFailed.tr(),
        ),
    };
    return DecoratedBox(
      // Always solid white with a hairline — a proper header bar (matching the
      // unified tab-page header), not the old transparent-until-scrolled fade.
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const HeaderBackButton(),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconWidget(
                      icon: AppAssets.svg.chat,
                      color: AppColors.textSecondary,
                      height: 19.h, // between the 18/20 tokens
                      width: 19.w,
                    ),
                    8.szW,
                    Text(
                      order.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle()
                          .setMainTextColor
                          .s16
                          .bold
                          .withHeight(20 / 16)
                          .tabular,
                    ),
                  ],
                ),
                // COD note sits directly under the order ID (red). Capped at a
                // single secondary line so the bar matches the unified header
                // height (the appointment time lives in the detail body).
                if (order.cod) ...[
                  4.szH,
                  Text(
                    LocaleKeys.orderDetailCodNote.tr(),
                    style: const TextStyle()
                        .setColor(AppColors.failedText)
                        .s12
                        .semiBold,
                  ),
                ],
              ],
            ),
          ),
          12.szW,
          // Status badge — a single element (no dot), vertically centered.
          Container(
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(AppCircular.r8),
            ),
            child: Text(
              pillLabel,
              style: const TextStyle().setColor(pillFg).s12.semiBold,
            ).paddingSymmetric(
              horizontal: AppPadding.pW12,
              vertical: AppPadding.pH4,
            ),
          ),
        ],
      ).paddingOnly(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH16,
      ),
    );
  }
}
