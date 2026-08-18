part of '../imports/order_flow_imports.dart';

/// The two follow-up actions below the summary — continue the route (primary)
/// and back to home (secondary).
class _ResultActions extends StatelessWidget {
  const _ResultActions({this.onContinue, this.onHome});
  final VoidCallback? onContinue;
  final VoidCallback? onHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 54.h, // primary action height
          decoration: BoxDecoration(
            color: AppColors.inkFill,
            borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconWidget(
                icon: AppAssets.svg.nav,
                color: AppColors.surface,
                height: 19.h, // between the 18/20 tokens
                width: 19.w,
              ),
              8.szW,
              Text(
                LocaleKeys.resultContinue.tr(),
                style: const TextStyle().setWhite.s14.bold,
              ),
            ],
          ),
        ).onClick(onTap: onContinue),
        12.szH,
        Container(
          height: AppSize.sH48,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
            border: Border.all(color: AppColors.borderDefault),
          ),
          alignment: Alignment.center,
          child: Text(
            LocaleKeys.resultHome.tr(),
            style: const TextStyle().setTertiaryColor.s14.bold,
          ),
        ).onClick(onTap: onHome ?? () => Navigator.of(context).maybePop()),
      ],
    ).paddingOnly(
      left: AppPadding.pW24,
      right: AppPadding.pW24,
      bottom: AppPadding.pH16,
    );
  }
}
