part of '../imports/auth_imports.dart';

/// The Orderbase brand mark for the login screen (Auth.dc.html 1a). The mockup
/// uses `assets/brand/orderbase.svg`, which isn't in this repo — so this is a
/// token-built placeholder: an ink-black rounded tile holding the courier (bag)
/// glyph, with the wordmark beneath. Swap for the real logo when it ships.
class _AuthBrandLockup extends StatelessWidget {
  const _AuthBrandLockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: AppSize.sH64,
          width: AppSize.sW64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.inkFill,
            borderRadius: BorderRadius.circular(AppCircular.r18),
          ),
          child: IconWidget(
            icon: AppAssets.svg.bag,
            color: AppColors.surface,
            height: AppSize.sH32,
            width: AppSize.sH32,
          ),
        ),
        12.szH,
        Text(LocaleKeys.authBrandName.tr(),
            style: const TextStyle().setMainTextColor.s20.extraBold),
      ],
    );
  }
}
