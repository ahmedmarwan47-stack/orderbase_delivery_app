/// The **droplet** tab bar: a second bar in this package, contributed by
/// Mohammed Hafiz.
///
/// Where the default bar ([package:liquid_tab_bar/liquid_tab_bar.dart]) makes
/// its selection lens a pane of glass in its own right, this one keeps the
/// lens a contained pill and refracts the icons and labels *behind* it
/// through a dedicated shader, only while it moves. It also carries a
/// [LiquidTabBarScaffold] that wires up scroll folding and bottom padding for
/// you, an expandable search field, separate action buttons and badges.
///
/// Import one bar or the other. Their type names overlap by design — both
/// call their widget `LiquidTabBar` and their theme `LiquidTabBarTheme` — so
/// an app that wants both must prefix at least one:
///
/// ```dart
/// import 'package:liquid_tab_bar/liquid_tab_bar.dart';
/// import 'package:liquid_tab_bar/droplet.dart' as droplet;
/// ```
library;

export 'src/droplet/bar.dart';
export 'src/droplet/controller.dart';
export 'src/droplet/glass.dart'
    show DropletRefractionStyle, GlassStyle, LiquidGlass;
export 'src/droplet/scaffold.dart';
export 'src/droplet/scroll_padding.dart';
export 'src/droplet/theme.dart';
