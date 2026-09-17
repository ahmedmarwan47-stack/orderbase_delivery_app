/// An iOS 26-style floating liquid-glass tab bar.
///
/// Three material tiers (refraction shader, backdrop blur, opaque), a
/// selection lens that slides on a spring, stretches with its speed and
/// disperses light like a soap bubble while a finger drags it, and a bar
/// that folds into a pill as the page scrolls. See [LiquidTabBar].
library;

export 'src/bar.dart';
export 'src/controller.dart';
export 'src/glass.dart' show DropletRefractionStyle, GlassStyle, LiquidGlass;
export 'src/scaffold.dart';
export 'src/scroll_padding.dart';
export 'src/theme.dart';
