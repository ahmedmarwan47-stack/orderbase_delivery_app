part of '../imports/order_flow_imports.dart';

/// Dark cash-on-delivery payment card.
class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.amount});

  /// The cash-to-collect amount label, e.g. "1,200".
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r18), // mockup radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.orderDetailCashLabel.tr(),
                style: const TextStyle()
                    .setColor(AppColors.paymentLabel)
                    .s12
                    .regular,
              ),
              4.szH,
              Text.rich(
                TextSpan(
                  text: amount,
                  style: const TextStyle()
                      .setWhite
                      .s20
                      .extraBold
                      .withHeight(1)
                      .tabular,
                  children: [
                    TextSpan(
                      text: ' ${LocaleKeys.orderDetailEgpSuffix.tr()}',
                      style: const TextStyle()
                          .setColor(AppColors.paymentSuffix)
                          .s14
                          .bold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 46.w, // fixed icon tile from the mockup
            height: 46.h,
            decoration: BoxDecoration(
              color: AppColors.paymentTile,
              borderRadius: BorderRadius.circular(AppCircular.r13),
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.cash,
                color: AppColors.cashBright,
                height: AppSize.sH24,
                width: AppSize.sW24,
              ),
            ),
          ),
        ],
      ).paddingSymmetric(
        horizontal: AppPadding.pW20,
        vertical: AppPadding.pH16,
      ),
    );
  }
}
