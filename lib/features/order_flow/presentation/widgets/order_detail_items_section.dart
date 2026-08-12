part of '../imports/order_flow_imports.dart';

/// Items block — title then two item rows (the first divided from the second).
class _ItemsSection extends StatelessWidget {
  const _ItemsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconWidget(
              icon: AppAssets.svg.bag,
              color: AppColors.textPrimary,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ),
            8.szW,
            Text(
              LocaleKeys.orderDetailItemsTitle.tr(),
              style: const TextStyle().setMainTextColor.s14.bold,
            ),
          ],
        ).paddingOnly(bottom: AppPadding.pH8),
        const _ItemRow(withDivider: true),
        const _ItemRow(withDivider: false),
      ],
    );
  }
}

/// A single order line — merchant thumb, name/variant/weight, and quantity.
class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.withDivider});
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppPadding.pH12,
        bottom: withDivider ? AppPadding.pH12 : AppPadding.pH4,
      ),
      decoration: withDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.itemDivider)),
            )
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 84.w, // fixed thumb width from the mockup
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppCircular.r12),
                child: Image.asset(AppAssets.img.fudgeCake, fit: BoxFit.cover),
              ),
            ),
            12.szW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.orderDetailItemName.tr(),
                    style: const TextStyle().setMainTextColor.s14.bold,
                  ),
                  4.szH,
                  Text(
                    LocaleKeys.orderDetailItemVariant.tr(),
                    style: const TextStyle().setSecondaryColor.s12.regular,
                  ),
                  4.szH,
                  Text(
                    LocaleKeys.orderDetailItemWeight.tr(),
                    style: const TextStyle().setTertiaryColor.s12.bold.tabular,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 34.w, // fixed quantity column width from the mockup
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  '×2',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle().setMainTextColor.s16.extraBold.tabular,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
