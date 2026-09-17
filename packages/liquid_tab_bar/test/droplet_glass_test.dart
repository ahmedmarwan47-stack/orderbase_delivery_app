import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/droplet.dart';
import 'package:liquid_tab_bar/src/droplet/glass.dart';
import 'package:liquid_tab_bar/src/droplet/test_overrides.dart';

void main() {
  group('DropletGlass Optical Refraction Engine', () {
    setUp(() {
      LiquidGlassTestOverrides.forceSupported = true;
    });

    tearDown(() {
      LiquidGlassTestOverrides.forceSupported = false;
    });

    testWidgets('DropletGlassSurface mounts with tight bounds and ClipRRect', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DropletGlassSurface(
                size: const Size(120, 64),
                radius: 32,
                style: const GlassStyle(),
              ),
            ),
          ),
        ),
      );

      // Verify tight bounding box and clipping
      expect(find.byType(DropletGlassSurface), findsOneWidget);
      final sizeFinder = find.byType(SizedBox).first;
      final sizedBox = tester.widget<SizedBox>(sizeFinder);
      expect(sizedBox.width, 120);
      expect(sizedBox.height, 64);

      final clipRRectFinder = find.byType(ClipRRect);
      expect(clipRRectFinder, findsOneWidget);
      final clipRRect = tester.widget<ClipRRect>(clipRRectFinder);
      expect(clipRRect.borderRadius, BorderRadius.circular(32));
    });

    testWidgets(
      'LiquidTabBar mounts DropletGlassSurface above icons when glass tier is active',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidTabBar(
                material: LiquidTabBarMaterial.glass,
                selectedIndex: selectedIndex,
                onSelected: (i) => selectedIndex = i,
                items: [
                  LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                  LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                  LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                  LiquidTabItem.icon(
                    icon: Icons.library_music,
                    label: 'Library',
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // DropletGlassSurface should be present
        expect(find.byType(DropletGlassSurface), findsOneWidget);

        // Each tab icon widget is rendered exactly once (no duplicates!)
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.fiber_new), findsOneWidget);
        expect(find.byIcon(Icons.radio), findsOneWidget);
        expect(find.byIcon(Icons.library_music), findsOneWidget);

        // Labels are rendered exactly once
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Radio'), findsOneWidget);
        expect(find.text('Library'), findsOneWidget);
      },
    );

    testWidgets(
      'Droplet moves across tabs while icon widgets remain completely stationary',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                      LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                      LiquidTabItem.icon(
                        icon: Icons.library_music,
                        label: 'Library',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Record original stationary icon centers
        final homeCenter0 = tester.getCenter(find.byIcon(Icons.home));
        final newCenter0 = tester.getCenter(find.byIcon(Icons.fiber_new));
        final radioCenter0 = tester.getCenter(find.byIcon(Icons.radio));
        final libraryCenter0 = tester.getCenter(
          find.byIcon(Icons.library_music),
        );

        // Tap Library tab: triggers smooth transition Home -> Library
        await tester.tap(find.text('Library'), warnIfMissed: false);
        await tester.pump(); // Start animation
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Halfway through transition (over New / Radio)

        // Verify that icon positions in the widget tree have NOT moved a single pixel
        expect(tester.getCenter(find.byIcon(Icons.home)), homeCenter0);
        expect(tester.getCenter(find.byIcon(Icons.fiber_new)), newCenter0);
        expect(tester.getCenter(find.byIcon(Icons.radio)), radioCenter0);
        expect(
          tester.getCenter(find.byIcon(Icons.library_music)),
          libraryCenter0,
        );

        // Complete transition
        await tester.pumpAndSettle();

        // Even settled on Library, icon centers remain completely untouched
        expect(tester.getCenter(find.byIcon(Icons.home)), homeCenter0);
        expect(tester.getCenter(find.byIcon(Icons.fiber_new)), newCenter0);
        expect(tester.getCenter(find.byIcon(Icons.radio)), radioCenter0);
        expect(
          tester.getCenter(find.byIcon(Icons.library_music)),
          libraryCenter0,
        );

        // And exactly one of each icon exists
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.fiber_new), findsOneWidget);
        expect(find.byIcon(Icons.radio), findsOneWidget);
        expect(find.byIcon(Icons.library_music), findsOneWidget);
      },
    );

    testWidgets(
      'Optical refraction is motion-only: 0.0 at rest, active during slide, 0.0 when settled',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                      LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                      LiquidTabItem.icon(
                        icon: Icons.library_music,
                        label: 'Library',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // At rest on Home: motionStrength MUST be 0.0 (no residual distortion)
        var dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        var droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, 0.0);

        // Tap Library: initiate transition
        await tester.tap(find.byIcon(Icons.library_music), warnIfMissed: false);
        await tester.pump(); // Frame 0 of animation
        await tester.pump(
          const Duration(milliseconds: 60),
        ); // Mid-flight crossing New/Radio

        // While moving across tabs: motionStrength MUST be active (> 0.5)
        dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, greaterThan(0.5));

        // Settle on Library
        await tester.pumpAndSettle();

        // Settled on Library: motionStrength MUST return to strictly 0.0
        dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, 0.0);

        // Wait several seconds: verify zero residual optical displacement
        await tester.pump(const Duration(seconds: 3));
        dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, 0.0);

        // Tap back to Home: reverse transition
        await tester.tap(find.byIcon(Icons.home), warnIfMissed: false);
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 60),
        ); // Mid-flight returning

        dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, greaterThan(0.5));

        // Fully settled on Home
        await tester.pumpAndSettle();
        dropletFinder = find.byType(DropletGlassSurface);
        expect(dropletFinder, findsOneWidget);
        droplet = tester.widget<DropletGlassSurface>(dropletFinder);
        expect(droplet.motionStrength, 0.0);
      },
    );

    testWidgets(
      'Tapping the currently selected tab does not trigger refraction',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                      LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                      LiquidTabItem.icon(
                        icon: Icons.library_music,
                        label: 'Library',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Home while Home is already selected
        await tester.tap(find.byIcon(Icons.home), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 16));
        var droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(droplet.motionStrength, 0.0);

        await tester.pump(const Duration(milliseconds: 100));
        droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(droplet.motionStrength, 0.0);
      },
    );

    testWidgets(
      'Every tab (Home, New, Radio, Library) settles with exactly zero distortion',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                      LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                      LiquidTabItem.icon(
                        icon: Icons.library_music,
                        label: 'Library',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final tabIcons = [
          Icons.home,
          Icons.fiber_new,
          Icons.radio,
          Icons.library_music,
        ];
        for (final icon in tabIcons) {
          await tester.tap(find.byIcon(icon), warnIfMissed: false);
          await tester.pumpAndSettle();
          final droplet = tester.widget<DropletGlassSurface>(
            find.byType(DropletGlassSurface),
          );
          expect(
            droplet.motionStrength,
            0.0,
            reason: 'Tab $icon must settle with strictly 0.0 motionStrength',
          );
        }
      },
    );

    testWidgets(
      'Rapid direction reversals settle cleanly with zero residual motionStrength',
      (tester) async {
        int selectedIndex = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.fiber_new, label: 'New'),
                      LiquidTabItem.icon(icon: Icons.radio, label: 'Radio'),
                      LiquidTabItem.icon(
                        icon: Icons.library_music,
                        label: 'Library',
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Library
        await tester.tap(find.byIcon(Icons.library_music), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 30));

        // Reversal: quickly tap Home before reaching Library
        await tester.tap(find.byIcon(Icons.home), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 20));

        // Reversal 2: tap Radio before reaching Home
        await tester.tap(find.byIcon(Icons.radio), warnIfMissed: false);

        // Allow all animations to settle
        await tester.pumpAndSettle();

        final droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(
          droplet.motionStrength,
          0.0,
          reason:
              'Multiple rapid reversals must leave exactly zero residual motionStrength',
        );
      },
    );

    test('DropletRefractionStyle defaults match calibrated optical values', () {
      const style = DropletRefractionStyle();
      expect(style.thickness, 13.0);
      expect(style.rim, 13.0);
      expect(style.refractiveIndex, 1.50);
      expect(style.baseHeight, 18.0);
      expect(style.depth, 18.0);
      expect(style.dispersion, 0.0);
      expect(style.specularStrength, 0.15);
      expect(style.refractionStrength, 1.0);
    });

    test('All built-in presets keep dispersion at 0.0 by default', () {
      const presets = [
        DropletRefractionStyle.none(),
        DropletRefractionStyle.subtle(),
        DropletRefractionStyle.medium(),
        DropletRefractionStyle.strong(),
      ];
      for (final p in presets) {
        expect(
          p.dispersion,
          0.0,
          reason:
              'Preset $p must keep dispersion at 0.0 for clean native glass',
        );
      }
    });

    test('DropletRefractionStyle.none disables optical displacement only', () {
      const none = DropletRefractionStyle.none();
      expect(none.refractionStrength, 0.0);
      expect(none.thickness, 13.0);
      expect(none.refractiveIndex, 1.50);
      expect(none.baseHeight, 18.0);
      expect(none.specularStrength, 0.15);
    });

    test(
      'DropletRefractionStyle presets have correct relative optical ordering',
      () {
        const subtle = DropletRefractionStyle.subtle();
        const medium = DropletRefractionStyle.medium();
        const strong = DropletRefractionStyle.strong();

        expect(subtle.refractionStrength, lessThan(medium.refractionStrength));
        expect(medium.refractionStrength, lessThan(strong.refractionStrength));

        expect(subtle.thickness, lessThan(medium.thickness));
        expect(medium.thickness, lessThan(strong.thickness));

        expect(subtle.baseHeight, lessThan(medium.baseHeight));
        expect(medium.baseHeight, lessThan(strong.baseHeight));

        expect(subtle.refractiveIndex, lessThan(medium.refractiveIndex));
        expect(medium.refractiveIndex, lessThan(strong.refractiveIndex));
      },
    );

    test('DropletRefractionStyle throws AssertionError on invalid inputs', () {
      expect(
        () => DropletRefractionStyle(thickness: 0.5),
        throwsAssertionError,
      );
      expect(
        () => DropletRefractionStyle(refractiveIndex: 0.9),
        throwsAssertionError,
      );
      expect(
        () => DropletRefractionStyle(baseHeight: -1.0),
        throwsAssertionError,
      );
      expect(
        () => DropletRefractionStyle(dispersion: -0.1),
        throwsAssertionError,
      );
      expect(
        () => DropletRefractionStyle(specularStrength: -0.5),
        throwsAssertionError,
      );
      expect(
        () => DropletRefractionStyle(refractionStrength: -0.1),
        throwsAssertionError,
      );
    });

    test('DropletRefractionStyle copyWith, lerp, equality and hashCode', () {
      const a = DropletRefractionStyle(
        thickness: 14.0,
        refractiveIndex: 1.55,
        baseHeight: 20.0,
        dispersion: 0.05,
        specularStrength: 0.20,
        refractionStrength: 1.25,
      );

      final b = a.copyWith(refractionStrength: 1.50);
      expect(b.refractionStrength, 1.50);
      expect(b.thickness, 14.0);

      final c = a.copyWith();
      expect(c, equals(a));
      expect(c.hashCode, equals(a.hashCode));

      final lerped = DropletRefractionStyle.lerp(
        const DropletRefractionStyle(refractionStrength: 1.0),
        const DropletRefractionStyle(refractionStrength: 2.0),
        0.5,
      );
      expect(lerped.refractionStrength, closeTo(1.5, 0.001));

      expect(a.toString(), contains('DropletRefractionStyle('));
    });

    testWidgets(
      'LiquidTabBar passes custom dropletRefraction to DropletGlassSurface',
      (tester) async {
        const customRefraction = DropletRefractionStyle(
          thickness: 15.0,
          refractiveIndex: 1.60,
          baseHeight: 22.0,
          dispersion: 0.02,
          specularStrength: 0.30,
          refractionStrength: 1.75,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidTabBar(
                material: LiquidTabBarMaterial.glass,
                selectedIndex: 0,
                dropletRefraction: customRefraction,
                items: [
                  LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                  LiquidTabItem.icon(icon: Icons.search, label: 'Search'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(droplet.refractionStyle, equals(customRefraction));
        expect(droplet.refractionStyle!.thickness, 15.0);
        expect(droplet.refractionStyle!.refractionStrength, 1.75);
      },
    );

    testWidgets(
      'Extreme custom refraction parameters still settle with 0.0 motionStrength',
      (tester) async {
        const extreme = DropletRefractionStyle(
          thickness: 24.0,
          refractiveIndex: 2.0,
          baseHeight: 40.0,
          dispersion: 0.5,
          specularStrength: 0.5,
          refractionStrength: 3.0,
        );

        int selectedIndex = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return LiquidTabBar(
                    material: LiquidTabBarMaterial.glass,
                    selectedIndex: selectedIndex,
                    dropletRefraction: extreme,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: [
                      LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                      LiquidTabItem.icon(icon: Icons.search, label: 'Search'),
                    ],
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap tab 1
        await tester.tap(find.byIcon(Icons.search), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));

        // Settle
        await tester.pumpAndSettle();

        final droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(
          droplet.motionStrength,
          0.0,
          reason:
              'Even with extreme refractionStrength: 3.0, settled state must have strictly 0.0 motionStrength',
        );
      },
    );

    testWidgets(
      'DropletRefractionStyle.none preserves normal droplet visuals and sets refractionStrength to 0',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LiquidTabBar(
                material: LiquidTabBarMaterial.glass,
                selectedIndex: 0,
                dropletRefraction: const DropletRefractionStyle.none(),
                items: [
                  LiquidTabItem.icon(icon: Icons.home, label: 'Home'),
                  LiquidTabItem.icon(icon: Icons.search, label: 'Search'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final droplet = tester.widget<DropletGlassSurface>(
          find.byType(DropletGlassSurface),
        );
        expect(droplet.refractionStyle!.refractionStrength, 0.0);

        // Normal droplet decorations and icons are present
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
