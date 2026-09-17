/// An iOS 26-style floating liquid-glass tab bar.
///
/// Three material tiers (refraction shader, backdrop blur, opaque), a
/// selection lens that slides on a spring, stretches with its speed and
/// disperses light like a soap bubble while a finger drags it, balloons past
/// the capsule under a press while the glass magnifies the tab it holds, and
/// a bar that folds into a pill as the page scrolls. See [LiquidTabBar].
///
/// This is the package's original bar and its default import. A second bar —
/// the **droplet** variant, with a scaffold, an expandable search field,
/// separate actions and badges — lives at
/// `package:liquid_tab_bar/droplet.dart`. The two are independent: pick one
/// per app, or import both behind prefixes.
library;

export 'src/classic/bar.dart';
export 'src/classic/controller.dart';
export 'src/classic/glass.dart';
export 'src/classic/theme.dart';
