part of '../imports/pickup_imports.dart';

/// One ready-to-collect order: merchant thumb, number + pay pill, customer name,
/// and area·pieces meta.
class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.order});
  final FlowOrder order;

  @override
  Widget build(BuildContext context) {
    final payLabel =
        order.cod ? LocaleKeys.pickupPayCod.tr() : LocaleKeys.pickupPayPaid.tr();
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 84.w, // fixed thumb width (no matching token)
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
                  Row(
                    children: [
                      Text(
                        order.num,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle().setMainTextColor.s16.extraBold,
                      ),
                      8.szW,
                      Container(
                        decoration: BoxDecoration(
                          color: payBg,
                          borderRadius: BorderRadius.circular(7.r), // pay pill
                        ),
                        child: Text(
                          payLabel,
                          style: const TextStyle().setColor(payFg).s12.bold,
                        ).paddingSymmetric(
                          horizontal: AppPadding.pW8,
                          vertical: AppPadding.pH4,
                        ),
                      ),
                    ],
                  ),
                  4.szH,
                  Text(
                    order.name,
                    style: const TextStyle().setColor(AppColors.textBody).s14.semiBold,
                  ),
                  4.szH,
                  Text(
                    order.meta,
                    style: const TextStyle().setSecondaryColor.s12.regular,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingAll(AppPadding.pH16),
    );
  }
}
