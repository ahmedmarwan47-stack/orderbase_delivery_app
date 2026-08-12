part of '../imports/order_flow_imports.dart';

/// Amber customer-notes card.
class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(18.r), // mockup radius
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconWidget(
                icon: AppAssets.svg.note,
                color: AppColors.postponedText,
                height: AppSize.sH18,
                width: AppSize.sW18,
              ),
              8.szW,
              Text(
                LocaleKeys.orderDetailNotesTitle.tr(),
                style: const TextStyle()
                    .setColor(AppColors.postponedText)
                    .s14
                    .bold,
              ),
            ],
          ),
          8.szH,
          Text(
            LocaleKeys.orderDetailNotesBody.tr(),
            style: const TextStyle()
                .setColor(AppColors.postponedTextStrong)
                .s14
                .regular
                .withHeight(1.6),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}
