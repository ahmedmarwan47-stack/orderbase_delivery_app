import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

/// The iOS-style home-indicator pill on a white strip, as it appears at the
/// bottom of every screen in the mockups. Used by screens that have no tab bar
/// (Pickup, Result, Auth, the search mode of the Orders tab).
///
/// It is deliberately NOT part of [BottomNav] any more: the tab bar now floats
/// as a translucent pill, and an opaque white strip welded under it would draw
/// a crisp band through the blur — the one thing glass must never sit on. The
/// pill's own bottom margin clears the real home indicator instead.
class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    // Centred with a Row, not `Container(alignment:)`: an aligned Container
    // expands to whatever bounded height it is offered, and in a Scaffold's
    // `bottomNavigationBar` slot that is the whole screen — a white sheet over
    // the page. A Row is only ever as tall as the pill inside it.
    return ColoredBox(
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 135.w, // fixed iOS home-indicator pill — no token
            height: 5.h,
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AppCircular.r3),
            ),
          ),
        ],
      ).paddingSymmetric(vertical: AppPadding.pH8),
    );
  }
}
