part of '../imports/home_imports.dart';

/// Dark "total collected today" banner with the big cash figure (Glance / 1b).
class _HomeCollectionBanner extends StatelessWidget {
  const _HomeCollectionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(AppCircular.r20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.deepDropShadow, // 0 10px 26px -14px rgba(0,0,0,.5)
            offset: Offset(0, 10),
            blurRadius: 26,
            spreadRadius: -14,
          ),
        ],
      ),
      padding: EdgeInsets.all(AppPadding.pW20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.homeTotalCollectedToday.tr(),
                style: const TextStyle().setColor(AppColors.paymentLabel).s12.regular,
              ),
              8.szH,
              Text.rich(
                TextSpan(
                  text: '22,500',
                  style: const TextStyle()
                      .setColor(AppColors.cashBright)
                      .extraBold
                      .tabular
                      .withHeight(1)
                      .copyWith(fontSize: FontSizeManager.s24), // was s28
                  children: [
                    TextSpan(
                      text: ' ${LocaleKeys.homeEgp.tr()}',
                      style:
                          const TextStyle().setColor(AppColors.cashSuffixGreen).s16.bold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 50.w, // mockup 50px (off the 4px grid)
            height: 50.h,
            decoration: BoxDecoration(
              color: AppColors.cashTileWash,
              borderRadius: BorderRadius.circular(AppCircular.r15),
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.cash,
                color: AppColors.cashBright,
                height: 26.h, // mockup glyph 26px
                width: 26.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
