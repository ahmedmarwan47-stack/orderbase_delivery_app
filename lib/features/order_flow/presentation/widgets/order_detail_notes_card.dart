part of '../imports/order_flow_imports.dart';

/// Amber customer-notes card.
class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(AppCircular.r18), // mockup radius
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
                    .semiBold,
              ),
            ],
          ),
          8.szH,
          Text(
            note,
            style: const TextStyle()
                .setColor(AppColors.postponedTextStrong)
                .s12
                .regular
                .withHeight(1.5),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}
