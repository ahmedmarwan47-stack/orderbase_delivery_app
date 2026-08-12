import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icon names ported from the design project's icon set (`i-<name>` symbols
/// in the `.dc.html` mockups). Add new ones here as new screens need them —
/// keep the Dart name matching the mockup's `i-` id (minus the prefix) so
/// it's easy to trace a screen's `<use href="#i-x">` back to its asset.
enum AppIconName {
  search,
  x,
  chevronRight, // i-cr
  chevronLeft, // i-cl
  clock,
  check,
  undo,
  phone,
  wallet,
  home,
  orders,
  bell,
  more,
  nav,
  pin,
  bike,
  fail,
  cash,
  chat,
  user,
  bag,
  note,
  cam,
}

extension on AppIconName {
  String get assetName => switch (this) {
    AppIconName.chevronRight => 'chevron_right',
    AppIconName.chevronLeft => 'chevron_left',
    _ => name,
  };
}

/// Renders a ported mockup icon. The source SVGs are stroke-only artwork
/// (`stroke="#000000"`), recolored here via [color] to match `currentColor`
/// in the original — same technique, just applied at render time instead of
/// via CSS.
class AppIcon extends StatelessWidget {
  const AppIcon(this.name, {super.key, required this.color, this.size = 24});

  final AppIconName name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/${name.assetName}.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
