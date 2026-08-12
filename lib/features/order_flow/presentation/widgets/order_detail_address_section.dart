part of '../imports/order_flow_imports.dart';

/// Address block — pinned address line, the map preview, and open-on-map.
class _AddressSection extends StatelessWidget {
  const _AddressSection({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconWidget(
              icon: AppAssets.svg.pin,
              color: AppColors.brand,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ).paddingOnly(top: AppPadding.pH2),
            8.szW,
            Expanded(
              child: Text(
                address,
                style: const TextStyle()
                    .setColor(AppColors.textBody)
                    .s14
                    .regular
                    .withHeight(1.7),
              ),
            ),
          ],
        ),
        12.szH,
        MapView(
          height: 140.h,
          borderRadius: AppCircular.r16,
          pinDiameter: 34.w,
          pinIconSize: 18.w,
          pinVerticalAlignment: -0.04,
        ),
        12.szH,
        _OutlineActionButton(
          icon: AppAssets.svg.nav,
          iconColor: AppColors.brand,
          label: LocaleKeys.orderDetailOpenMap.tr(),
          fg: AppColors.textPrimary,
          border: AppColors.borderDefault,
          background: AppColors.surface,
          height: AppSize.sH48,
        ),
      ],
    );
  }
}
