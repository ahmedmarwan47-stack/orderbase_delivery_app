part of '../imports/order_flow_imports.dart';

/// Customer block — label + name, then the call / whatsapp action buttons.
class _CustomerSection extends StatelessWidget {
  const _CustomerSection({required this.name});

  /// The customer's display name.
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconWidget(
                  icon: AppAssets.svg.user,
                  color: AppColors.textPrimary,
                  height: AppSize.sH18,
                  width: AppSize.sW18,
                ),
                8.szW,
                Text(
                  LocaleKeys.orderDetailCustomer.tr(),
                  style: const TextStyle().setMainTextColor.s14.semiBold,
                ),
              ],
            ),
            Text(
              name,
              style: const TextStyle().setMainTextColor.s16.semiBold,
            ),
          ],
        ),
        16.szH,
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                icon: AppAssets.svg.phone,
                label: LocaleKeys.orderDetailCall.tr(),
                // Call = blue, WhatsApp = green — a contact accent per channel,
                // distinct from the failed-red / delivered-green status hues.
                fg: AppColors.transitBg,
                border: AppColors.transitBg,
                background: AppColors.surface,
              ).onClick(onTap: AppHaptics.tap),
            ),
            12.szW,
            Expanded(
              child: _OutlineActionButton(
                icon: AppAssets.svg.chat,
                label: LocaleKeys.orderDetailWhatsapp.tr(),
                fg: AppColors.whatsappGreen,
                border: AppColors.whatsappGreen,
                background: AppColors.surface,
              ).onClick(onTap: AppHaptics.tap),
            ),
          ],
        ),
      ],
    );
  }
}
