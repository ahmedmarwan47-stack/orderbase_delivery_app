part of '../imports/profile_imports.dart';

/// «وضع الطريق» and its follow-the-route switch, as one surface. Listens to
/// [RoadMode] itself so the switch always shows what the hero is doing — the
/// route can flip the mode while the courier is sitting on this tab.
class _RoadModeGroup extends StatelessWidget {
  const _RoadModeGroup();

  @override
  Widget build(BuildContext context) {
    final mode = RoadMode.instance;
    return ListenableBuilder(
      listenable: mode,
      builder: (_, _) => _ProfileGroup(
        children: [
          _ProfileSwitchRow(
            icon: AppAssets.svg.nav,
            label: LocaleKeys.profileRoadMode.tr(),
            description: LocaleKeys.profileRoadModeDesc.tr(),
            value: mode.on,
            onChanged: (v) {
              AppHaptics.tick();
              mode.on = v;
            },
          ),
          _ProfileSwitchRow(
            label: LocaleKeys.profileRoadAuto.tr(),
            description: LocaleKeys.profileRoadAutoDesc.tr(),
            value: mode.auto,
            indented: true,
            last: true,
            onChanged: (v) {
              AppHaptics.tick();
              mode.auto = v;
            },
          ),
        ],
      ),
    );
  }
}

/// A profile row whose action is a switch: glyph, label with a one-line
/// description under it, the switch at the end. The whole row toggles, so the
/// target is the row and not the 50pt switch.
class _ProfileSwitchRow extends StatelessWidget {
  const _ProfileSwitchRow({
    this.icon,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
    this.indented = false,
    this.last = false,
  });

  final String? icon;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// A sub-setting: sits under the glyph column of the row above.
  final bool indented;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: AppColors.itemDivider)),
        ),
        child:
            Row(
              children: [
                if (icon != null)
                  IconWidget(
                    icon: icon!,
                    color: AppColors.textPrimary,
                    height: AppSize.sH20,
                    width: AppSize.sW20,
                  )
                else if (indented)
                  SizedBox(width: AppSize.sW20),
                16.szW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle().setMainTextColor.s14.semiBold,
                      ),
                      2.szH,
                      Text(
                        description,
                        style: const TextStyle().setSecondaryColor.s12.regular
                            .withHeight(1.4),
                      ),
                    ],
                  ),
                ),
                12.szW,
                // Ink for "on", like every committed control in the app —
                // never a status green.
                Switch.adaptive(
                  value: value,
                  onChanged: onChanged,
                  activeTrackColor: AppColors.inkFill,
                ),
              ],
            ).paddingOnly(
              left: AppPadding.pW20,
              right: AppPadding.pW12,
              top: AppPadding.pH12,
              bottom: AppPadding.pH12,
            ),
      ).onClick(onTap: () => onChanged(!value)),
    );
  }
}
