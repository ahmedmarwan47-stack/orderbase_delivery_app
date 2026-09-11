import 'package:liquid_tab_bar/liquid_tab_bar.dart';

export 'package:liquid_tab_bar/liquid_tab_bar.dart'
    show LiquidTabBarController, LiquidTabBarMaterial;

/// How the tab bar's surface is drawn — the package's tiers under the app's
/// old name. [NavMaterial.auto] picks the richest tier the device can carry;
/// the others pin one (the Account tab's dev row).
typedef NavMaterial = LiquidTabBarMaterial;

/// The app's one tab-bar controller: fold state and material tier, shared by
/// every bar. The tab bar itself lives in `packages/liquid_tab_bar` now; this
/// is the app's handle on its shared instance, so the shell, the header and
/// the dev rows keep their old spelling.
class NavBarController {
  NavBarController._();

  static final LiquidTabBarController instance = LiquidTabBarController.shared;
}
