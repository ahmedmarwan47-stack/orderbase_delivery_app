part of '../imports/orders_imports.dart';

/// Order card — merchant thumb, number + pay pill, name, meta, and a COD row
/// when cash is due. Only the top row is tappable (opens the detail step).
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final FlowOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Pay pill is derived purely from the COD flag, matching the mockup.
    final payKey = order.cod ? LocaleKeys.ordersPayCod : LocaleKeys.ordersPayPaid;
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MerchantThumb(size: AppSize.sH88),
              16.szW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: AppSize.sW8,
                      runSpacing: AppSize.sH4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          order.num,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle().setMainTextColor.s16.bold,
                        ),
                        _PayPill(labelKey: payKey, fg: payFg, bg: payBg),
                      ],
                    ),
                    4.szH,
                    Text(order.name,
                        style: const TextStyle().setMainTextColor.s18.semiBold),
                    4.szH,
                    Text(order.meta,
                        style: const TextStyle().setHintColor.s14.regular),
                  ],
                ),
              ),
            ],
          ).onClick(onTap: onTap),
          if (order.cod) ...[
            12.szH,
            _CodRow(amount: order.amount ?? ''),
          ],
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// Small pay/status pill next to the order number.
class _PayPill extends StatelessWidget {
  const _PayPill({required this.labelKey, required this.fg, required this.bg});

  final String labelKey;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r7), // 7px pill (radii exempt from 4px rule)
      ),
      child: Text(labelKey.tr(), style: const TextStyle().setColor(fg).s12.semiBold)
          .paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// The "cash to collect" divider row (shown only for COD orders).
class _CodRow extends StatelessWidget {
  const _CodRow({required this.amount});
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceSubtle)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(LocaleKeys.codRequired.tr(),
              style: const TextStyle().setSecondaryColor.s12.regular),
          Text(
            LocaleKeys.amountEgp.tr(namedArgs: {'amount': amount}),
            style: const TextStyle().setMainTextColor.s16.bold.tabular,
          ),
        ],
      ).paddingOnly(top: AppPadding.pH12),
    );
  }
}

/// Merchant image tile (rounded, cover).
class _MerchantThumb extends StatelessWidget {
  const _MerchantThumb({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppCircular.r12),
        image: DecorationImage(
          image: AssetImage(AppAssets.img.fudgeCake),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
