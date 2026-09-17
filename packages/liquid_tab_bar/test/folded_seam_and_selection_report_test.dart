import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

/// Regression / investigation tests for two independently reported issues:
///
///   A. A flat/straight cut on the FOLDED circle's right edge (glass tier,
///      `together` action placement) — visually the same seam the
///      ClipRect→ClipRRect fix in GlassSurface addressed in the expanded state.
///   B. The selection appearing to jump to another tab with no tap.
///
/// The glass tier's FragmentProgram cannot run under `flutter test`, so the
/// roundness / clipping geometry is verified on tiers that DO render (opaque /
/// blur). GlassSurface shares the exact same `_surface` call site and the same
/// `radius + pad` clip formula for both the expanded capsule and the folded
/// circle, so a clean circle on those tiers plus the shared call-site is the
/// closest headless reproduction available.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------- Issue A ---------------------------------------------------------

  group('Issue A: folded circle seam / right-edge flat cut', () {
    // Closest headless mirror of `_LiquidTabBarState._geometry` for the Apple
    // Music configuration (4 tabs + search action, `together`, circle).
    test(
        'together-placement geometry: padded bounds overlap ONLY in the '
        'expanded state, never in the folded state', () {
      const double w = 390;
      const double actionSize = LiquidTabBar.barHeight; // 64
      const double actionGap = 12.0;
      const double glassPad = LiquidTabBar.barHeight * 0.375; // 24 == _glassPad
      const double minSideMargin = 12.0;
      const int n = 4;

      final maxUsableW = w - 2 * minSideMargin;
      final availableForBar = maxUsableW - actionSize - actionGap;
      final idealMaxSlotW = 76.0; // n >= 4 with action
      final maxBarW = n * idealMaxSlotW + 2 * 8.0;
      final barW = math.min(maxBarW, availableForBar);
      final totalGroupW = barW + actionGap + actionSize;
      final startX = math.max(minSideMargin, (w - totalGroupW) / 2);

      final expanded = Rect.fromLTWH(startX, 0, barW, LiquidTabBar.barHeight);
      final pill = Rect.fromLTWH(
        startX,
        0,
        LiquidTabBar.barHeight,
        LiquidTabBar.barHeight,
      );
      final action = Rect.fromLTWH(
        startX + barW + actionGap,
        0,
        actionSize,
        actionSize,
      );

      // Expanded: the bar capsule's padded room overlaps the action button's
      // padded room — the exact overlap the old ClipRect made a flat seam of.
      expect(
        expanded.inflate(glassPad).overlaps(action.inflate(glassPad)),
        isTrue,
        reason: 'expanded state: two glass pads overlap (old ClipRect seam '
            'case) — this is what the ClipRRect fix addressed',
      );

      // Folded: the 64x64 circle is pinned to the capsule's leading edge;
      // its padded box is far from the button's padded box.
      expect(
        pill.inflate(glassPad).overlaps(action.inflate(glassPad)),
        isFalse,
        reason: 'folded state: pill and action padded boxes must not overlap',
      );
      expect(
        pill.inflate(glassPad).right,
        lessThan(action.inflate(glassPad).left),
        reason: 'folded pill padded box sits well clear of the action button',
      );

      // And the gap is large (a wide margin of error), not a hair:
      final foldedGap =
          action.inflate(glassPad).left - pill.inflate(glassPad).right;
      expect(foldedGap, greaterThan(10.0));
    });

    test(
      'folded glass clip: ClipRRect radius+pad circle fully contains the '
      'capsule AND its drop shadow — no straight boundary can intersect it',
      () {
        const pad = 24.0;
        const capsuleRadius = LiquidTabBar.barHeight / 2; // 32
        final box = Size.square(LiquidTabBar.barHeight + 2 * pad); // 112x112

        // GlassSurface clips the padded box with circular(radius + pad).
        final clipCenter = box.center(Offset.zero);
        final clipRadius = capsuleRadius + pad;
        final clipRRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: clipCenter,
            width: box.width,
            height: box.height,
          ),
          Radius.circular(clipRadius),
        );

        // The shader capsule: circular(32) concentric with the clip.
        final capsuleRect = Rect.fromCenter(
          center: clipCenter,
          width: capsuleRadius * 2,
          height: capsuleRadius * 2,
        );

        for (final corner in <Offset>[
          capsuleRect.topLeft,
          capsuleRect.topRight,
          capsuleRect.bottomLeft,
          capsuleRect.bottomRight,
        ]) {
          expect(
            clipRRect.contains(corner),
            isTrue,
            reason: 'ClipRRect(radius + pad) fully wraps the 64x64 folded '
                'circle concentrically (corner $corner inside radius '
                '$clipRadius)',
          );
        }

        // Directly at the reported seam location (the right edge, equator row):
        // the clip circle extends 24 logical px beyond the capsule's rightmost
        // pixel, so the shader capsule's round silhouette is never cut there.
        final rightmostHorizontalInsetIntoClip =
            clipRadius - capsuleRadius; // 56 - 32 = 24
        expect(rightmostHorizontalInsetIntoClip, greaterThanOrEqualTo(20.0));

        // The folded style's drop shadow: blur 20 beyond the capsule, offset
        // (0, 6). Horizontally it stays inside the clip (52 <= 56); only its
        // faint bottom tail (offset push) reaches past the soft clip boundary —
        // a fading soft-shadow pixel, not a hard seam.
        const shadowBlur = 20.0;
        final shadowRight = clipCenter.dx + capsuleRadius + shadowBlur;
        expect(shadowRight, lessThanOrEqualTo(clipCenter.dx + clipRadius));
      },
    );

    testWidgets(
        'folded circle renders geometrically ROUND on its right edge '
        '(pixel scan, together placement)', (tester) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      const surface = Color(0xFFCC0000); // distinctly detectable capsule fill
      const theme = LiquidTabBarTheme(
        barStyle: LiquidBarStyle(
          opaqueFill: surface,
          opaqueEdge: Color(0xFF220000),
          shadow: [],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              controller: controller,
              material: LiquidTabBarMaterial.opaque,
              theme: theme,
              initiallyMinimized: true,
              selectedIndex: 0,
              separateAction: LiquidTabAction.icon(
                icon: Icons.search,
                tooltip: 'Search',
              ),
              separateActionPlacement: LiquidTabActionPlacement.together,
              items: [
                LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                LiquidTabItem.icon(label: 'New', icon: Icons.grid_view),
                LiquidTabItem.icon(label: 'Radio', icon: Icons.radio),
                LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);

      final pill = find.bySemanticsLabel('Expand navigation bar');
      expect(pill, findsOneWidget);
      final pillRect = tester.getRect(pill);
      expect(pillRect.width, equals(LiquidTabBar.barHeight));

      final boundaryFinder = find
          .descendant(
            of: find.byType(LiquidTabBar),
            matching: find.byType(RepaintBoundary),
          )
          .first;
      expect(boundaryFinder, findsOneWidget);
      final boundaryBox = tester.renderObject<RenderRepaintBoundary>(
        boundaryFinder,
      );
      final boundaryRect = tester.getRect(boundaryFinder);

      final pixelRatio = 3.0;
      final ui.Image? image = await tester.runAsync(
        () => boundaryBox.toImage(pixelRatio: pixelRatio),
      );
      expect(image, isNotNull);
      final byteData = await tester.runAsync(
        () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
      );
      expect(byteData, isNotNull);

      final data = byteData!.buffer.asUint8List();
      final imageW = image!.width;
      final imageH = image.height;

      bool isCapsule(int x, int y) {
        final o = (y * imageW + x) * 4;
        return data[o + 3] > 200 &&
            data[o] > 140 &&
            data[o + 1] < 90 &&
            data[o + 2] < 90;
      }

      // Pill-local right edge, in logical px, sampled at several rows in the
      // top half of the circle.
      final pillLeftPhysical = (pillRect.left - boundaryRect.left) * pixelRatio;
      final pillTopPhysical = (pillRect.top - boundaryRect.top) * pixelRatio;
      final sizePhysical = pillRect.width * pixelRatio;

      final rightEdges = <double>[];
      for (final row in [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0]) {
        final y = (pillTopPhysical + row * pixelRatio).round();
        if (y < 0 || y >= imageH) continue;
        double rightmost = -1;
        for (int x = (pillLeftPhysical + sizePhysical).round() - 1;
            x >= (pillLeftPhysical + sizePhysical * 0.55).round();
            x--) {
          if (x >= 0 && x < imageW && isCapsule(x, y)) {
            rightmost = (x - pillLeftPhysical) / pixelRatio;
            break;
          }
        }
        expect(
          rightmost,
          isNonNegative,
          reason: 'row ${row.toStringAsFixed(0)} should reach the capsule',
        );
        rightEdges.add(rightmost.toDouble());
      }

      final spread = rightEdges.reduce(math.max) - rightEdges.reduce(math.min);
      expect(
        spread,
        greaterThan(8.0),
        reason: 'a perfect 64px circle bows from ~47.5 to ~64 across rows '
            '4..28 (spread ~16); a flat vertical right-edge cut would keep the '
            'edge pinned near 64 on every row (spread ~0). Got $rightEdges.',
      );

      // Symmetry guard: the left edge must be round too.
      final leftEdges = <double>[];
      for (final row in [4.0, 8.0, 12.0, 16.0, 20.0, 24.0, 28.0]) {
        final y = (pillTopPhysical + row * pixelRatio).round();
        if (y < 0 || y >= imageH) continue;
        double leftmost = -1;
        for (int x = (pillLeftPhysical).round();
            x < (pillLeftPhysical + sizePhysical * 0.45).round();
            x++) {
          if (x >= 0 && x < imageW && isCapsule(x, y)) {
            leftmost = (x - pillLeftPhysical) / pixelRatio;
            break;
          }
        }
        expect(leftmost, isNonNegative);
        leftEdges.add(leftmost.toDouble());
      }
      expect(
        leftEdges.reduce(math.max) - leftEdges.reduce(math.min),
        greaterThan(8.0),
        reason: 'left edge also bows (round), not flat. Got $leftEdges.',
      );
    });
  });

  // -------- Issue B ---------------------------------------------------------

  group('Issue B: selection must not move without a tap', () {
    const accent = Color(0xFF25D366);

    Widget whatsAppStyleBar({
      required LiquidTabBarController controller,
      required int selected,
      required ValueChanged<int> onSelected,
    }) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          bottomNavigationBar: LiquidTabBar(
            controller: controller,
            material: LiquidTabBarMaterial.opaque,
            theme: const LiquidTabBarTheme(activeColor: accent),
            selectedIndex: selected,
            onSelected: onSelected,
            separateAction: LiquidTabAction.icon(
              icon: Icons.edit,
              tooltip: 'New Chat',
            ),
            items: [
              LiquidTabItem.icon(
                label: 'Chats',
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
              ),
              LiquidTabItem.icon(
                label: 'Updates',
                icon: Icons.circle_notifications_outlined,
                activeIcon: Icons.circle_notifications,
              ),
              LiquidTabItem.icon(
                label: 'Communities',
                icon: Icons.groups_outlined,
                activeIcon: Icons.groups,
              ),
              LiquidTabItem.icon(
                label: 'Calls',
                icon: Icons.call_outlined,
                activeIcon: Icons.call,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets(
        'scroll-fold (minimize) and expand never fire onSelected and '
        'never move the visually selected tab', (tester) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);
      var selected = 0;
      final calls = <int>[];

      await tester.pumpWidget(
        whatsAppStyleBar(
          controller: controller,
          selected: selected,
          onSelected: (i) {
            calls.add(i);
            selected = i;
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(selected, equals(0));

      // Chats is the active (filled) icon and Calls is inactive (outlined).
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.call_outlined), findsOneWidget);

      // Fold, hold folded across several frames (rebuilds), then expand.
      controller.minimize();
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      controller.expand();
      await tester.pumpAndSettle();
      expect(controller.minimized, isFalse);

      expect(
        calls,
        isEmpty,
        reason: 'no user tap occurred — selection must not change',
      );
      expect(selected, equals(0));
      expect(
        find.byIcon(Icons.chat_bubble),
        findsOneWidget,
        reason: 'Chats still visually selected after fold/unfold',
      );
      expect(
        find.byIcon(Icons.call_outlined),
        findsOneWidget,
        reason: 'Calls must stay inactive',
      );
      final chatsIcon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble));
      expect(chatsIcon.color, equals(accent));
    });

    testWidgets(
        'theme / MediaQuery rebuild while folded keeps selection and '
        'lens on the selected tab', (tester) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);
      var selected = 0;
      final calls = <int>[];
      late StateSetter appSetter;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setAppState) {
            appSetter = setAppState;
            return MaterialApp(
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: Colors.white,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: Colors.black,
              ),
              themeMode: ThemeMode.light,
              home: Builder(
                builder: (context) => Scaffold(
                  bottomNavigationBar: LiquidTabBar(
                    controller: controller,
                    material: LiquidTabBarMaterial.opaque,
                    theme: LiquidTabBarTheme.adaptive(context)
                        .copyWith(activeColor: accent),
                    selectedIndex: selected,
                    onSelected: (i) {
                      calls.add(i);
                      selected = i;
                    },
                    items: [
                      LiquidTabItem.icon(
                        label: 'Chats',
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                      ),
                      LiquidTabItem.icon(
                        label: 'Calls',
                        icon: Icons.call_outlined,
                        activeIcon: Icons.call,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      controller.minimize();
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        // Simulate the AppBar theme toggle rebuilding the subtree around the
        // bar while it sits folded.
        appSetter(() {});
        await tester.pumpAndSettle();
        controller.expand();
        await tester.pumpAndSettle();
        controller.minimize();
        await tester.pumpAndSettle();
      }
      controller.expand();
      await tester.pumpAndSettle();

      expect(calls, isEmpty);
      expect(selected, equals(0));
      final chatsIcon = tester.widget<Icon>(find.byIcon(Icons.chat_bubble));
      expect(chatsIcon.color, equals(accent));
    });

    testWidgets(
        'two contemporaneous bars with distinct controllers keep '
        'independent selection (no state leak between stacked screens)', (
      tester,
    ) async {
      final waController = LiquidTabBarController();
      addTearDown(waController.dispose);
      final amController = LiquidTabBarController();
      addTearDown(amController.dispose);

      var waSelected = 0;
      final waCalls = <int>[];
      var amSelected = 1;
      final amCalls = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  // Bar A (WhatsApp), selected 0.
                  LiquidTabBar(
                    controller: waController,
                    material: LiquidTabBarMaterial.opaque,
                    theme: const LiquidTabBarTheme(
                      activeColor: Color(0xFF25D366),
                    ),
                    selectedIndex: waSelected,
                    onSelected: (i) {
                      waCalls.add(i);
                      waSelected = i;
                    },
                    items: [
                      LiquidTabItem.icon(
                        label: 'Chats',
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                      ),
                      LiquidTabItem.icon(
                        label: 'Calls',
                        icon: Icons.call_outlined,
                        activeIcon: Icons.call,
                      ),
                    ],
                  ),
                  // Bar B (Apple Music), selected 1.
                  LiquidTabBar(
                    controller: amController,
                    material: LiquidTabBarMaterial.opaque,
                    theme: const LiquidTabBarTheme(
                      activeColor: Color(0xFFFA2D48),
                    ),
                    selectedIndex: amSelected,
                    onSelected: (i) {
                      amCalls.add(i);
                      amSelected = i;
                    },
                    items: [
                      LiquidTabItem.icon(
                        label: 'Home',
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                      ),
                      LiquidTabItem.icon(
                        label: 'Library',
                        icon: Icons.library_music_outlined,
                        activeIcon: Icons.library_music,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // A fresh rebuild of the sibling (mirroring the other route live in the
      // navigator) must not touch bar A's selection.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Column(
                children: [
                  LiquidTabBar(
                    controller: waController,
                    material: LiquidTabBarMaterial.opaque,
                    theme: const LiquidTabBarTheme(
                      activeColor: Color(0xFF25D366),
                    ),
                    selectedIndex: waSelected,
                    onSelected: (i) {
                      waCalls.add(i);
                      waSelected = i;
                    },
                    items: [
                      LiquidTabItem.icon(
                        label: 'Chats',
                        icon: Icons.chat_bubble_outline,
                        activeIcon: Icons.chat_bubble,
                      ),
                      LiquidTabItem.icon(
                        label: 'Calls',
                        icon: Icons.call_outlined,
                        activeIcon: Icons.call,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(waCalls, isEmpty);
      expect(waSelected, equals(0));
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });

    testWidgets(
        'a cancelled press/scrub leaves selection and the lens on the '
        'selected tab', (tester) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);
      var selected = 0;
      final calls = <int>[];

      await tester.pumpWidget(
        whatsAppStyleBar(
          controller: controller,
          selected: selected,
          onSelected: (i) {
            calls.add(i);
            selected = i;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Press on the Calls slot (index 3), drag across it, then cancel mid-way.
      final callsLabel = find.text('Calls');
      final callsSlot = tester.getCenter(callsLabel);
      final gesture = await tester.startGesture(callsSlot);
      await tester.pump();
      await gesture.moveBy(const Offset(-20, 10));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();

      expect(calls, isEmpty, reason: 'cancelled gesture must not choose a tab');
      expect(selected, equals(0));

      // A real tap afterwards still works, proving the bar did not wedge.
      await tester.tap(find.text('Calls'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(calls, [3]);
      expect(selected, equals(3));
    });
  });
}
