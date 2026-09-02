part of '../imports/pickup_imports.dart';

/// Sticky footer: the single confirm-pickup action plus a note that confirming
/// flips every order to "in transit".
class _PickupConfirmBar extends StatelessWidget {
  const _PickupConfirmBar({required this.count, this.onConfirm});
  final int count;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      child:
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: AppSize.sH56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.inkFill,
                  borderRadius: BorderRadius.circular(
                    AppCircular.r15,
                  ), // confirm button radius
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconWidget(
                      icon: AppAssets.svg.check,
                      color: AppColors.surface,
                      height: AppSize.sH18,
                      width: AppSize.sW18,
                    ),
                    8.szW,
                    Text(
                      LocaleKeys.pickupConfirm.tr(
                        namedArgs: {'count': '$count'},
                      ),
                      style: const TextStyle().setWhite.s14.semiBold,
                    ),
                  ],
                ),
              ).onClick(onTap: onConfirm),
              8.szH,
              Text(
                LocaleKeys.pickupConfirmHint.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle().setSecondaryColor.s12.regular,
              ),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH16,
            bottom: AppPadding.pH12,
          ),
    );
  }
}
