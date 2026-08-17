part of '../imports/settlement_imports.dart';

/// The locked-scope note: prepaid and failed orders never enter the settlement.
class _LockedNote extends StatelessWidget {
  const _LockedNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.photoTile,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconWidget(
            icon: AppAssets.svg.lock,
            color: AppColors.textMuted,
            height: AppSize.sH16,
            width: AppSize.sW16,
          ),
          12.szW,
          Expanded(
            child: Text(
              LocaleKeys.settlementLockedNote.tr(),
              style: const TextStyle()
                  .setColor(AppColors.textMuted)
                  .s12
                  .regular
                  .withHeight(1.5),
            ),
          ),
        ],
      ).paddingAll(AppPadding.pW12),
    );
  }
}
