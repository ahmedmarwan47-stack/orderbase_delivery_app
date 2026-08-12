part of '../imports/order_flow_imports.dart';

/// White header — back row, order number + date, the transit status pill and
/// the COD note.
class _OrderDetailHeader extends StatelessWidget {
  const _OrderDetailHeader();

  @override
  Widget build(BuildContext context) {
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
                          '#89289',
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
                      LocaleKeys.orderDetailDate.tr(),
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
                      color: AppColors.transitBg,
                      borderRadius: BorderRadius.circular(AppCircular.r8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _Dot(color: AppColors.surface, size: 7),
                        8.szW,
                        Text(
                          LocaleKeys.orderDetailStatusTransit.tr(),
                          style: const TextStyle().setWhite.s12.bold,
                        ),
                      ],
                    ).paddingSymmetric(
                      horizontal: AppPadding.pW8,
                      vertical: AppPadding.pH4,
                    ),
                  ),
                  8.szH,
                  Text(
                    LocaleKeys.orderDetailCodNote.tr(),
                    style: const TextStyle()
                        .setColor(AppColors.failedText)
                        .s12
                        .bold,
                  ),
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
