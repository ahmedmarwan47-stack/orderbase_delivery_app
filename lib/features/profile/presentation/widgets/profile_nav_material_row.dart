part of '../imports/profile_imports.dart';

/// Dev: pin the tab bar's material tier. «تلقائي» lets the device decide —
/// glass where Impeller runs the shader, blur elsewhere, and a step down to
/// blur if frames start dropping; the rest force one tier so the three can
/// be compared on the same phone. Tapping cycles through them.
class _NavMaterialRow extends StatelessWidget {
  const _NavMaterialRow();

  static const _order = [
    NavMaterial.auto,
    NavMaterial.glass,
    NavMaterial.blur,
    NavMaterial.opaque,
  ];

  String _name(NavMaterial m) => switch (m) {
    NavMaterial.auto => LocaleKeys.navMaterialAuto.tr(),
    NavMaterial.glass => LocaleKeys.navMaterialGlass.tr(),
    NavMaterial.blur => LocaleKeys.navMaterialBlur.tr(),
    NavMaterial.opaque => LocaleKeys.navMaterialOpaque.tr(),
  };

  @override
  Widget build(BuildContext context) {
    final c = NavBarController.instance;
    return ListenableBuilder(
      listenable: c,
      builder: (_, _) {
        final pinned = c.material;
        // What is actually on screen, when auto resolved it to something.
        final value = pinned == NavMaterial.auto
            ? '${_name(pinned)} · ${_name(c.effectiveMaterial)}'
            : _name(pinned);
        return DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.itemDivider)),
          ),
          child:
              Row(
                children: [
                  IconWidget(
                    icon: AppAssets.svg.more,
                    color: AppColors.textPrimary,
                    height: AppSize.sH20,
                    width: AppSize.sW20,
                  ),
                  16.szW,
                  Expanded(
                    child: Text(
                      LocaleKeys.profileNavMaterial.tr(),
                      style: const TextStyle().setMainTextColor.s14.semiBold,
                    ),
                  ),
                  12.szW,
                  Text(
                    value,
                    style: const TextStyle().setSecondaryColor.s12.regular,
                  ),
                ],
              ).paddingOnly(
                left: AppPadding.pW20,
                right: AppPadding.pW20,
                top: AppPadding.pH12,
                bottom: AppPadding.pH12,
              ),
        ).onClick(
          onTap: () {
            AppHaptics.tick();
            c.material = _order[(_order.indexOf(pinned) + 1) % _order.length];
          },
        );
      },
    );
  }
}
