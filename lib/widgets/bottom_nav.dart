import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../app/road_mode.dart';
import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import '../theme/shadows.dart';

/// The four sections of the app. Batches and orders are one tab: a batch is
/// how orders arrive, so the Orders tab lists them grouped by batch.
enum NavTab { home, orders, settlement, profile }

/// The floating tab bar — a pill inset from all three edges, hovering over the
/// page rather than sitting on a shelf at the bottom of it. Its material is
/// liquid glass, hand-rolled: the page is blurred and saturated behind a 70%
/// white fill, with a sheen down its face and a light rim. No package, no
/// native code — this app has no Podfile and keeps it that way.
///
/// **It only works because the page passes underneath it.** Every host puts it
/// in `Scaffold(extendBody: true)`'s `bottomNavigationBar` slot and gives its
/// scrollable [reservedHeight] of bottom padding; a blur over a flat page fill
/// is just an opaque bar with extra frames.
///
/// Two gates render the opaque twin instead — same pill, solid fill, no
/// [BackdropFilter] at all:
///  * `MediaQuery.highContrastOf` — Flutter exposes no reduce-transparency
///    flag, and this is the honest proxy for the same intent.
///  * [RoadMode] — «وضع الطريق» exists for sun on the screen and gloves on the
///    grips. Translucency is its direct enemy, so this is an interlock, not a
///    preference.
///
/// [active] is null on pages that are not a tab — notifications, opened from
/// the header, sits inside the shell with no tab highlighted. The Orders tab
/// carries a red dot while a batch waits at the branch; that dot is the app's
/// standing "something is waiting" signal, so this widget watches
/// [ShiftController] directly instead of depending on its host to redraw.
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

  /// The pill's own height, before its margins.
  static double get barHeight => AppSize.sH64;

  /// Vertical space the bar occupies at the bottom of a page — the pill, the
  /// gap it floats above the home indicator, and a little breathing room over
  /// it. Every scrollable behind the bar needs this much bottom padding, or
  /// its last row hides under the pill forever.
  ///
  /// Inside a `Scaffold(extendBody: true)` body the framework already hands
  /// down a MediaQuery whose bottom padding is the *measured* height of
  /// everything in the `bottomNavigationBar` slot — this pill plus any sticky
  /// action bar stacked with it — so prefer that when it is the larger of the
  /// two. Off that path (a hand-rolled Stack, or a call from above the
  /// Scaffold) the pill's own geometry is the answer.
  static double reservedHeight(BuildContext context) => math.max(
    barHeight + _bottomGap(context) + AppPadding.pH12,
    MediaQuery.paddingOf(context).bottom,
  );

  /// How far the pill floats above the screen edge: clear of the home
  /// indicator where there is one, a plain margin where there is not.
  static double _bottomGap(BuildContext context) =>
      math.max(MediaQuery.viewPaddingOf(context).bottom, AppMargin.mH12);

  /// Blur, then saturate — Apple's own order, and the numbers Flutter's own
  /// Cupertino tab bar encodes. [ui.TileMode.clamp] matters: without it the
  /// blur samples transparent black past the clip and the pill's edges bleed
  /// dark.
  static final ui.ImageFilter _glass = ui.ImageFilter.compose(
    outer: const ColorFilter.matrix(_saturate),
    inner: ui.ImageFilter.blur(
      sigmaX: 10,
      sigmaY: 10,
      tileMode: ui.TileMode.clamp,
    ),
  );

  /// Saturation ×1.6 about the Rec. 709 luminance axis.
  static const List<double> _saturate = <double>[
    1.47244, -0.42912, -0.04332, 0, 0, //
    -0.12756, 1.17088, -0.04332, 0, 0, //
    -0.12756, -0.42912, 1.55668, 0, 0, //
    0, 0, 0, 1, 0, //
  ];

  /// Bottom scroll edge effect — page colour rising from nothing at the top of
  /// the bar's strip to solid at the screen edge. The stops are weighted late
  /// so the dissolve happens close to the edge rather than washing the whole
  /// strip out.
  static const LinearGradient _edgeFade = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.navEdgeFadeClear, AppColors.navEdgeFadeSolid],
    stops: [0.15, 0.85],
  );

  static const LinearGradient _sheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.navGlassSheenTop, AppColors.navGlassSheenBottom],
  );

  @override
  Widget build(BuildContext context) {
    // Listens to the shift itself rather than trusting the host page to
    // rebuild: the Orders badge is now the ONLY signal that a batch is waiting
    // at the branch, and a batch can land while the courier is sitting still
    // on a tab that never rebuilds. Road mode joins it because it decides
    // whether the bar is glass at all.
    return AnimatedBuilder(
      animation: Listenable.merge([
        ShiftController.instance,
        RoadMode.instance,
      ]),
      builder: (context, _) => _bar(context),
    );
  }

  Widget _bar(BuildContext context) {
    // No BackdropFilter at all when gated — mirroring cupertino_ui's own
    // `opaque()` pattern rather than blurring into an invisible result.
    final opaque = MediaQuery.highContrastOf(context) || RoadMode.instance.on;
    // A capsule, not a fixed radius: at phone scale a floating control's
    // corner is half its own height, so the shape follows [barHeight] instead
    // of being re-guessed whenever that changes.
    final radius = BorderRadius.circular(AppCircular.infinity);

    Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: opaque ? AppColors.surface : AppColors.navGlassFill,
        borderRadius: radius,
        border: Border.all(
          color: opaque ? AppColors.navOpaqueEdge : AppColors.navGlassEdge,
        ),
      ),
      child: SizedBox(height: barHeight, child: _items()),
    );
    if (!opaque) {
      pill = DecoratedBox(
        decoration: const BoxDecoration(gradient: _sheen),
        child: pill,
      );
      pill = BackdropFilter(filter: _glass, child: pill);
    }

    final bar = Container(
      // A capsule needs more clearance from the screen edge than a rounded
      // rectangle does — its widest point is its middle, so at 12 the curve
      // reads as if it were about to touch the bezel.
      margin: EdgeInsetsDirectional.only(
        start: AppMargin.mW16,
        end: AppMargin.mW16,
        bottom: _bottomGap(context),
      ),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadows.floatingBar,
      ),
      child: ClipRRect(borderRadius: radius, child: pill),
    );

    // The scroll edge effect. Content passing *behind* the pill is blurred by
    // it, but content in the gutters beside it and in the gap below it reaches
    // the screen edge with nothing between it and the bezel — a row sliced in
    // half by the end of the screen. The fade dissolves it into the page
    // first. Painted before the pill, so the blur samples it too.
    //
    // It fades to [AppColors.background] because every screen that hosts this
    // bar is on that fill; a white-page host would need its own colour.
    return Stack(
      children: [
        const Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(decoration: BoxDecoration(gradient: _edgeFade)),
          ),
        ),
        bar,
      ],
    );
  }

  Widget _items() {
    return Row(
      children: [
        _item(
          NavTab.home,
          AppAssets.svg.home,
          LocaleKeys.navHome.tr(),
          activeIcon: AppAssets.svg.homeFilled,
        ),
        _item(
          NavTab.orders,
          AppAssets.svg.orders,
          LocaleKeys.navOrders.tr(),
          activeIcon: AppAssets.svg.ordersFilled,
          // Red dot while a batch is waiting to be carried from the branch —
          // it clears the moment the batch is in hand.
          badge: ShiftController.instance.hasPendingBatch,
        ),
        _item(
          NavTab.settlement,
          AppAssets.svg.wallet,
          LocaleKeys.navSettlement.tr(),
          activeIcon: AppAssets.svg.walletFilled,
        ),
        _item(
          NavTab.profile,
          AppAssets.svg.user,
          LocaleKeys.navProfile.tr(),
          activeIcon: AppAssets.svg.userFilled,
        ),
      ],
    );
  }

  Widget _item(
    NavTab tab,
    String icon,
    String label, {
    String? activeIcon,
    bool badge = false,
  }) {
    final isActive = tab == active;
    return Expanded(
      child: _NavItem(
        // Active tab renders the filled (solid) glyph; inactive keeps the
        // stroke one. Both are still recolored via IconWidget's srcIn filter.
        icon: isActive ? (activeIcon ?? icon) : icon,
        label: label,
        active: isActive,
        badge: badge,
        onTap: onTap == null ? null : () => onTap!(tab),
      ),
    );
  }
}

/// One tab: a filled rounded chip behind the icon + label when it is the
/// current one, nothing behind it when it is not. The chip is content-sized but
/// the tap target is the full quarter of the bar.
class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final bool badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.dangerAccent : AppColors.textSecondary;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: active,
        child: SizedBox.expand(
          child: Center(
            child: AnimatedContainer(
              duration: AppMotion.stamp,
              curve: AppMotion.ease,
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.pW12,
                vertical: AppPadding.pH4,
              ),
              decoration: BoxDecoration(
                color: active ? AppColors.navActiveChip : AppColors.transparent,
                // Concentric with the pill: inner radius = parent radius minus
                // the inset between them. The parent is a capsule, so that
                // arithmetic lands on half this chip's own height — a capsule
                // too, at whatever height the icon and label add up to.
                borderRadius: BorderRadius.circular(AppCircular.infinity),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconWidget(
                        icon: icon,
                        color: color,
                        height: 23.h, // 23px glyph — no matching AppSize token
                        width: 23.w,
                      ),
                      if (badge)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 7.w, // 7px badge dot — no AppSize token
                            height: 7.h,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  4.szH,
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (active
                                ? const TextStyle().semiBold
                                : const TextStyle().regular)
                            .s12
                            .setColor(color),
                  ),
                ],
              ),
            ),
          ).onClick(onTap: onTap),
        ),
      ),
    );
  }
}
