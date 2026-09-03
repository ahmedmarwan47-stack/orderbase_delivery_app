import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/colors.dart';

/// iOS-style status bar: `9:41` on one side, signal/wifi/battery glyph on the
/// other. Always LTR (the clock and glyph don't flip), matching the mockups'
/// `dir="ltr"` on this row even inside an RTL screen.
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, this.background = AppColors.surface});

  final Color background;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: background,
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '9:41',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/status_bar.svg',
              width: 66,
              height: 13,
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
