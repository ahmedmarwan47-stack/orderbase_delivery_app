part of '../imports/auth_imports.dart';

/// The green WhatsApp info card (Auth.dc.html 1b): a delivered-green wash with a
/// leading chat glyph, a bold title, and a body line — telling the courier the
/// code arrives on WhatsApp.
class _AuthInfoCard extends StatelessWidget {
  const _AuthInfoCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: AppColors.deliveredBorder),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW16, vertical: AppPadding.pH12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: AppAssets.svg.chat,
            color: AppColors.deliveredText,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle()
                        .setColor(AppColors.deliveredText)
                        .s14
                        .semiBold),
                4.szH,
                Text(body,
                    style: const TextStyle()
                        .setColor(AppColors.deliveredText)
                        .s14
                        .regular
                        .withHeight(1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
