part of '../imports/home_imports.dart';

/// Green "you're online now" bar with an on-state toggle (Glance / 1b).
class _HomeOnlineBar extends StatelessWidget {
  const _HomeOnlineBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h, // mockup 50px (off the 4px grid)
      padding: EdgeInsetsDirectional.only(
        start: AppPadding.pW16,
        end: AppPadding.pW8,
      ),
      decoration: BoxDecoration(
        color: AppColors.deliveredBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.onlineBarBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: AppSize.sW8,
            children: [
              Container(
                width: 9.w, // 9px status dot (off the 4px grid)
                height: 9.h,
                decoration: BoxDecoration(
                  color: AppColors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.onlineDotGlow,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
              Text(
                LocaleKeys.homeOnlineNow.tr(),
                style: const TextStyle()
                    .setColor(AppColors.deliveredText)
                    .s14
                    .semiBold,
              ),
            ],
          ),
          // on-state toggle
          Container(
            width: 52.w, // toggle track (off the 4px grid)
            padding: EdgeInsets.all(AppPadding.pW4),
            decoration: BoxDecoration(
              color: AppColors.greenAccent,
              borderRadius: BorderRadius.circular(AppCircular.r16),
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(
                width: AppSize.sW24,
                height: AppSize.sH24,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
