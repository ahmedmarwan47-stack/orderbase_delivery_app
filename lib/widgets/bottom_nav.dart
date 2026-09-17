import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

import '../app/road_mode.dart';
import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import '../theme/shadows.dart';
import 'nav_bar_controller.dart';

/// The four sections of the app. Batches and orders are one tab: a batch is
/// how orders arrive, so the Orders tab lists them grouped by batch.
enum NavTab { home, orders, settlement, profile }

/// The app's tab bar: [LiquidTabBar] from `packages/liquid_tab_bar` — the
/// glass, the soap-bubble lens, the scrub, the fold — dressed in the app's
/// tokens. Everything about how the bar looks and moves lives in the package;
/// this widget only says what the four tabs are.
///
/// It watches [ShiftController] itself rather than trusting the host page to
/// rebuild: the Orders badge is the ONLY signal that a batch is waiting at the
/// branch, and a batch can land while the courier is sitting still on a tab
/// that never rebuilds. [RoadMode] forces the opaque tier — sun and gloves.
///
/// Put it in `Scaffold(extendBody: true)`'s `bottomNavigationBar` slot and
/// give the scrollable [reservedHeight] of bottom padding. In the app that
/// host is the shell — ONE bar over every tab page; a page carries its own
/// copy only standalone. [active] is null on pages that are not a tab.
class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.active,
    this.notificationsBadge = false,
    this.onTap,
  });

  final NavTab? active;
  final bool notificationsBadge;
  final ValueChanged<NavTab>? onTap;

  /// The bar's height when open.
  static const double barHeight = LiquidTabBar.barHeight;

  /// Vertical space the bar occupies at the bottom of a page.
  static double reservedHeight(BuildContext context) =>
      LiquidTabBar.reservedHeight(context);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ShiftController.instance,
        RoadMode.instance,
      ]),
      builder: (context, _) => LiquidTabBar(
        items: [
          for (final tab in NavTab.values)
            LiquidTabItem.icon(
              label: _label(tab),
              // The app draws its own stroke SVGs, so [icon] is never used —
              // [iconBuilder] wins. It is required all the same, so it carries
              // the nearest Material glyph as a placeholder.
              icon: _fallbackIcon(tab),
              iconBuilder: (color, selected) => IconWidget(
                icon: selected ? _activeIcon(tab) : _icon(tab),
                color: color,
                height: 23,
                width: 23,
              ),
              // Red dot while a batch is waiting to be carried from the
              // branch — it clears the moment the batch is in hand.
              badge:
                  tab == NavTab.orders &&
                  ShiftController.instance.hasPendingBatch,
            ),
        ],
        selectedIndex: active?.index,
        onSelected: (i) => onTap?.call(NavTab.values[i]),
        controller: NavBarController.instance,
        theme: LiquidTabBarTheme(
          activeColor: AppColors.dangerAccent,
          inactiveColor: AppColors.textPrimary,
          labelStyle: const TextStyle().s12,
          barStyle: LiquidBarStyle(
            blurTint: AppColors.navGlassTint,
            blurSheenTop: AppColors.navGlassSheenTop,
            blurSheenBottom: AppColors.navGlassSheenBottom,
            blurEdge: AppColors.navGlassEdge,
            opaqueFill: AppColors.surface,
            opaqueEdge: AppColors.navOpaqueEdge,
            shadow: AppShadows.floatingBar,
          ),
          dropletSurfaceStyle: LiquidDropletSurfaceStyle.light.copyWith(
            opaqueFill: AppColors.navLensTint,
          ),
          badgeStyle: const LiquidBadgeStyle(
            color: AppColors.brand,
            borderColor: AppColors.surface,
          ),
          spring: AppMotion.spring,
          relax: AppMotion.tick,
        ),
        material: RoadMode.instance.on ? LiquidTabBarMaterial.opaque : null,
        haptic: AppHaptics.tick,
      ),
    );
  }

  /// The bar's labels drop the definite article («رئيسية», not «الرئيسية») —
  /// the page headers keep the «ال» form.
  String _label(NavTab t) => switch (t) {
    NavTab.home => LocaleKeys.tabHome.tr(),
    NavTab.orders => LocaleKeys.tabOrders.tr(),
    NavTab.settlement => LocaleKeys.tabSettlement.tr(),
    NavTab.profile => LocaleKeys.tabProfile.tr(),
  };

  String _icon(NavTab t) => switch (t) {
    NavTab.home => AppAssets.svg.home,
    NavTab.orders => AppAssets.svg.orders,
    NavTab.settlement => AppAssets.svg.wallet,
    NavTab.profile => AppAssets.svg.user,
  };

  /// Required by [LiquidTabItem.icon] and never drawn: the app's own
  /// [iconBuilder] replaces it on every tab.
  IconData _fallbackIcon(NavTab t) => switch (t) {
    NavTab.home => Icons.home_outlined,
    NavTab.orders => Icons.receipt_long_outlined,
    NavTab.settlement => Icons.account_balance_wallet_outlined,
    NavTab.profile => Icons.person_outline,
  };

  /// The filled twin, for the selected tab only.
  String _activeIcon(NavTab t) => switch (t) {
    NavTab.home => AppAssets.svg.homeFilled,
    NavTab.orders => AppAssets.svg.ordersFilled,
    NavTab.settlement => AppAssets.svg.walletFilled,
    NavTab.profile => AppAssets.svg.userFilled,
  };
}
