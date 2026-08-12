import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';

/// The iOS-style home-indicator pill on a white strip, as it appears at the
/// bottom of every screen in the mockups. Used inside [BottomNav] and directly
/// on screens that have no tab bar (e.g. Pickup).
class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(vertical: AppPadding.pH8),
      alignment: Alignment.center,
      child: Container(
        width: 135.w, // fixed iOS home-indicator pill — no token
        height: 5.h,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(3.r),
        ),
      ),
    );
  }
}
