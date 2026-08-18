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
    final (Color pillBg, Color pillFg, Color dotColor, String pillLabel) =
        switch (order.state) {
      FlowOrderState.active => (
          AppColors.transitBg,
          AppColors.transitText,
          AppColors.surface,
          LocaleKeys.orderDetailStatusTransit.tr(),
        ),
      FlowOrderState.done => (
          AppColors.deliveredBg,
          AppColors.deliveredText,
          AppColors.deliveredText,
          LocaleKeys.orderDetailStatusDone.tr(),
        ),
      FlowOrderState.failed => (
          AppColors.failedBg,
          AppColors.failedText,
          AppColors.failedText,
          LocaleKeys.orderDetailStatusFailed.tr(),
        ),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Fade the SAME white in/out (transparent-white, never transparent-
        // black) so the transition never flashes a dark tint.
        color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderHeader.withValues(alpha: scrolled ? 1 : 0),
          ),
        ),
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
                          .extraBold
                          .withHeight(20 / 16)
                          .tabular,
                    ),
                  ],
                ),
                4.szH,
                Text(
                  order.dateLabel,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle().setSecondaryColor.s14.regular,
                ),
              ],
            ),
          ),
          12.szW,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(AppCircular.r8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _Dot(color: dotColor, size: 7),
                    8.szW,
                    Text(
                      pillLabel,
                      style: const TextStyle().setColor(pillFg).s12.bold,
                    ),
                  ],
                ).paddingSymmetric(
                  horizontal: AppPadding.pW8,
                  vertical: AppPadding.pH4,
                ),
              ),
              if (order.cod) ...[
                8.szH,
                Text(
                  LocaleKeys.orderDetailCodNote.tr(),
                  style: const TextStyle()
                      .setColor(AppColors.failedText)
                      .s12
                      .bold,
                ),
              ],
            ],
          ),
        ],
      ).paddingOnly(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH12,
      ),
    );
  }
}
