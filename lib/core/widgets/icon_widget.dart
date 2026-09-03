import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../config/res/app_sizes.dart';

/// Renders an SVG asset (from [AppAssets]). Unlike Flutter_Base's pre-colored
/// icon set, this project's icons are monochrome stroke artwork, so `color` is
/// applied via a `srcIn` filter at render time (see `app_assets.dart`).
class IconWidget extends StatelessWidget {
  const IconWidget({
    super.key,
    required this.icon,
    this.height,
    this.width,
    this.color,
  });

  final String icon;
  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon,
      height: height ?? AppSize.sH24,
      width: width ?? height ?? AppSize.sW24,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
