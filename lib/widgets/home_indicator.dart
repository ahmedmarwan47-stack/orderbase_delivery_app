import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// The iOS-style home-indicator pill on a white strip, as it appears at the
/// bottom of every screen in the mockups. Used inside [BottomNav] and directly
/// on screens that have no tab bar (e.g. Pickup).
class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      child: Container(
        width: 135,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
