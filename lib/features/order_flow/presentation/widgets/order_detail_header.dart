part of '../imports/order_flow_imports.dart';

/// White header — back row, order number + date, a per-order status pill and
/// (for COD orders only) the red COD note. Everything is driven by [order].
class _OrderDetailHeader extends StatelessWidget {
  const _OrderDetailHeader({required this.order});

  /// The order being shown; drives the number, date, status pill and COD note.
  final FlowOrder order;

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
              IconWidget(
                icon: AppAssets.svg.chevronRight,
                color: AppColors.textTertiary,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Text(
                LocaleKeys.orderDetailBack.tr(),
                style: const TextStyle().setTertiaryColor.s14.semiBold,
              ),
            ],
          )
              .paddingSymmetric(vertical: AppPadding.pH8)
              .onClick(onTap: () => Navigator.of(context).maybePop()),
          4.szH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              .s24
                              .extraBold
                              .withHeight(28 / 24)
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
          ),
        ],
      ).paddingOnly(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH8,
        bottom: AppPadding.pH16,
      ),
    );
  }
}
