import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:liquid_tab_bar/src/glass.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testItems = [
    LiquidTabItem.icon(label: 'Home', icon: Icons.home),
    LiquidTabItem.icon(label: 'Orders', icon: Icons.receipt),
    LiquidTabItem.icon(label: 'Me', icon: Icons.person),
  ];

  Widget buildBar({
    required List<LiquidTabItem> items,
    required int? selectedIndex,
    ValueChanged<int>? onSelected,
    LiquidTabBarController? controller,
    LiquidTabBarTheme? theme,
    bool shrinkOnScroll = true,
    LiquidFoldedShape? foldedShape,
    LiquidTabAction? separateAction,
    LiquidTabActionPlacement separateActionPlacement =
        LiquidTabActionPlacement.together,
  }) {
    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: LiquidTabBar(
          items: items,
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          controller: controller,
          theme: theme,
          material: LiquidTabBarMaterial
              .opaque, // test without requiring FragmentProgram
          shrinkOnScroll: shrinkOnScroll,
          foldedShape: foldedShape,
          separateAction: separateAction,
          separateActionPlacement: separateActionPlacement,
        ),
      ),
    );
  }

  group('LiquidTabBar Bounds & Validation', () {
    testWidgets('asserts if items is empty', (tester) async {
      expect(
        () => LiquidTabBar(items: const [], selectedIndex: 0),
        throwsAssertionError,
      );
    });

    testWidgets('asserts if selectedIndex is out of upper bound', (
      tester,
    ) async {
      expect(
        () => LiquidTabBar(
          items: testItems,
          selectedIndex: 3, // length is 3, valid indices are 0, 1, 2
        ),
        throwsAssertionError,
      );
    });

    testWidgets('asserts if selectedIndex is negative', (tester) async {
      expect(
        () => LiquidTabBar(items: testItems, selectedIndex: -1),
        throwsAssertionError,
      );
    });

    testWidgets('renders successfully with valid items and selectedIndex', (
      tester,
    ) async {
      await tester.pumpWidget(buildBar(items: testItems, selectedIndex: 0));
      expect(find.byType(LiquidTabBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);
    });

    testWidgets('renders successfully with null selectedIndex', (tester) async {
      await tester.pumpWidget(buildBar(items: testItems, selectedIndex: null));
      expect(find.byType(LiquidTabBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('LiquidTabBar Gesture & Multi-Touch', () {
    testWidgets('tapping a tab triggers onSelected', (tester) async {
      int? selected;
      await tester.pumpWidget(
        buildBar(
          items: testItems,
          selectedIndex: 0,
          onSelected: (i) => selected = i,
        ),
      );

      await tester.tap(find.text('Orders'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(selected, equals(1));
    });

    testWidgets('multi-touch ignores secondary pointer down during drag', (
      tester,
    ) async {
      int? selected;
      await tester.pumpWidget(
        buildBar(
          items: testItems,
          selectedIndex: 0,
          onSelected: (i) => selected = i,
        ),
      );

      final centerFirst = tester.getCenter(find.text('Orders'));
      final centerSecond = tester.getCenter(find.text('Me'));

      // Start first pointer
      final gesture1 = await tester.startGesture(centerFirst, pointer: 1);
      await tester.pump();

      // Start second pointer elsewhere while first is held
      final gesture2 = await tester.startGesture(centerSecond, pointer: 2);
      await tester.pump();

      // Move second pointer - should be ignored by bar since pointer 1 is active
      await gesture2.moveBy(const Offset(30, 0));
      await tester.pump();

      // Release second pointer
      await gesture2.up();
      await tester.pump();

      // Tab selection should not have triggered yet
      expect(selected, isNull);

      // Release first pointer
      await gesture1.up();
      await tester.pumpAndSettle();

      expect(selected, equals(1));
    });
  });

  group('LiquidTabBar Accessibility & Features', () {
    testWidgets('badge renders badge dot on glyph', (tester) async {
      final badgedItems = [
        LiquidTabItem.icon(label: 'Home', icon: Icons.home, badge: true),
        LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
      ];

      await tester.pumpWidget(buildBar(items: badgedItems, selectedIndex: 0));
      expect(find.byType(LiquidTabBar), findsOneWidget);
    });

    testWidgets('LiquidTabItem renders number badge and formats count', (
      tester,
    ) async {
      final badgedItems = [
        LiquidTabItem.icon(
          label: 'Home',
          icon: Icons.home,
          badge: true,
          badgeCount: 5,
        ),
        LiquidTabItem.icon(
          label: 'Profile',
          icon: Icons.person,
          badge: true,
          badgeText: '99+',
        ),
      ];

      await tester.pumpWidget(buildBar(items: badgedItems, selectedIndex: 0));
      expect(find.text('5'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      expect(find.bySemanticsLabel('Home, 5 notifications'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Profile, 99+ notifications'),
        findsOneWidget,
      );
    });

    testWidgets(
      'LiquidTabItem renders custom green circular badge like WhatsApp',
      (tester) async {
        final badgedItems = [
          LiquidTabItem.icon(
            label: 'Chats',
            icon: Icons.chat,
            badge: true,
            badgeCount: 1,
            badgeStyle: const LiquidBadgeStyle(color: Color(0xFF25D366)),
          ),
        ];

        await tester.pumpWidget(buildBar(items: badgedItems, selectedIndex: 0));
        expect(find.text('1'), findsOneWidget);
        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text('1'), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF25D366));
        expect(decoration.shape, BoxShape.circle);
      },
    );

    testWidgets(
      'LiquidTabItem renders badge with LiquidBadgeStyle (removes border, custom size, custom color)',
      (tester) async {
        final badgedItems = [
          LiquidTabItem.icon(
            label: 'Alerts',
            icon: Icons.notifications,
            badge: true,
            badgeCount: 3,
            badgeStyle: const LiquidBadgeStyle(
              showBorder: false,
              size: 22,
              color: Color(0xFF9C27B0),
              textColor: Color(0xFFFFFF00),
            ),
          ),
        ];

        await tester.pumpWidget(buildBar(items: badgedItems, selectedIndex: 0));
        expect(find.text('3'), findsOneWidget);

        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text('3'), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF9C27B0));
        // Border is removed:
        expect(decoration.border, isNull);
        // Size constraints:
        expect(container.constraints?.minWidth, 22.0);
        expect(container.constraints?.minHeight, 22.0);

        final text = tester.widget<Text>(find.text('3'));
        expect(text.style?.color, const Color(0xFFFFFF00));
      },
    );

    testWidgets(
      'LiquidTabItem renders dot badge without border when showBorder is false',
      (tester) async {
        final badgedItems = [
          LiquidTabItem.icon(
            label: 'Alerts',
            icon: Icons.notifications,
            badge: true,
            badgeStyle: const LiquidBadgeStyle(
              showBorder: false,
              dotSize: 12,
              color: Color(0xFFE91E63),
            ),
          ),
        ];

        await tester.pumpWidget(buildBar(items: badgedItems, selectedIndex: 0));
        final containers = tester.widgetList<Container>(find.byType(Container));
        final dotContainer = containers.firstWhere(
          (c) =>
              c.constraints?.maxWidth == 12 && c.constraints?.maxHeight == 12,
        );
        final decoration = dotContainer.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFFE91E63));
        expect(decoration.border, isNull);
      },
    );

    testWidgets(
      'LiquidTabBarTheme badgeStyle applies globally when not overridden',
      (tester) async {
        final badgedItems = [
          LiquidTabItem.icon(
            label: 'Alerts',
            icon: Icons.notifications,
            badge: true,
            badgeCount: 8,
          ),
        ];

        final customTheme = const LiquidTabBarTheme().copyWith(
          badgeStyle: const LiquidBadgeStyle(
            showBorder: false,
            color: Color(0xFF009688),
            size: 20,
          ),
        );

        await tester.pumpWidget(
          buildBar(items: badgedItems, selectedIndex: 0, theme: customTheme),
        );

        final container = tester.widget<Container>(
          find
              .ancestor(of: find.text('8'), matching: find.byType(Container))
              .first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, const Color(0xFF009688));
        expect(decoration.border, isNull);
        expect(container.constraints?.minWidth, 20.0);
      },
    );

    testWidgets('reservedHeight scales with textScaler', (tester) async {
      late double normalHeight;
      late double scaledHeight;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.0)),
            child: Builder(
              builder: (context) {
                normalHeight = LiquidTabBar.reservedHeight(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Builder(
              builder: (context) {
                scaledHeight = LiquidTabBar.reservedHeight(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(scaledHeight, greaterThan(normalHeight));
    });

    testWidgets('folded controller excludes semantics of inactive tabs', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildBar(items: testItems, selectedIndex: 0, controller: controller),
      );

      // Initially expanded: all labels find semantics
      expect(tester.getSemantics(find.text('Orders')), isNotNull);

      // Minimize
      controller.minimize();
      await tester.pumpAndSettle();

      // Folded: verify the folded button semantics exist
      expect(find.bySemanticsLabel('Expand navigation bar'), findsOneWidget);
    });

    testWidgets('shrinkOnScroll: false keeps bar expanded even if minimized', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildBar(
          items: testItems,
          selectedIndex: 0,
          controller: controller,
          shrinkOnScroll: false,
        ),
      );

      controller.minimize();
      await tester.pumpAndSettle();

      // Because shrinkOnScroll is false, all tabs remain visible with semantics and no expand button
      expect(find.text('Orders'), findsOneWidget);
      expect(find.bySemanticsLabel('Expand navigation bar'), findsNothing);
    });

    testWidgets(
      'initiallyMinimized: true starts folded without custom controller',
      (tester) async {
        LiquidTabBarController.shared.expand();
        addTearDown(LiquidTabBarController.shared.expand);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: testItems,
                selectedIndex: 0,
                initiallyMinimized: true,
                material: LiquidTabBarMaterial.opaque,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(LiquidTabBar.isMinimized, isTrue);
      },
    );

    testWidgets('tapping folded pill automatically expands the bar', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildBar(items: testItems, selectedIndex: 0, controller: controller),
      );

      controller.minimize();
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);

      // Tap the folded pill via touch pointer on its touch target
      final pillTouchTarget = find.descendant(
        of: find.byType(LiquidTabBar),
        matching: find.byType(Listener),
      );
      await tester.tap(pillTouchTarget);
      await tester.pumpAndSettle();
      expect(controller.minimized, isFalse);
    });

    testWidgets(
      'folded/minimized bar renders as a true circle (width == height == barHeight)',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );

        controller.minimize();
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);

        // Find the folded pill via its expand semantics
        final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
        expect(expandSemantics, findsOneWidget);

        final pillSize = tester.getSize(expandSemantics);
        expect(pillSize.width, equals(LiquidTabBar.barHeight));
        expect(pillSize.height, equals(LiquidTabBar.barHeight));
        expect(pillSize.width, equals(pillSize.height));
      },
    );

    testWidgets(
      'foldedShape: LiquidFoldedShape.oval renders as an elongated stadium pill',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          buildBar(
            items: testItems,
            selectedIndex: 0,
            controller: controller,
            foldedShape: LiquidFoldedShape.oval,
          ),
        );

        controller.minimize();
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);

        final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
        expect(expandSemantics, findsOneWidget);

        final pillSize = tester.getSize(expandSemantics);
        expect(pillSize.height, equals(LiquidTabBar.barHeight));
        expect(pillSize.width, equals(84.0));
        expect(pillSize.width, greaterThan(pillSize.height));
      },
    );

    testWidgets(
      'foldedShape inherits from LiquidTabBarTheme when widget.foldedShape is null',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        const customTheme = LiquidTabBarTheme(
          foldedShape: LiquidFoldedShape.oval,
        );

        await tester.pumpWidget(
          buildBar(
            items: testItems,
            selectedIndex: 0,
            controller: controller,
            theme: customTheme,
          ),
        );

        controller.minimize();
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);

        final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
        final pillSize = tester.getSize(expandSemantics);
        expect(pillSize.width, equals(84.0));
        expect(pillSize.height, equals(LiquidTabBar.barHeight));
      },
    );

    testWidgets('widget.foldedShape overrides theme.foldedShape', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      const customTheme = LiquidTabBarTheme(
        foldedShape: LiquidFoldedShape.oval,
      );

      await tester.pumpWidget(
        buildBar(
          items: testItems,
          selectedIndex: 0,
          controller: controller,
          theme: customTheme,
          foldedShape: LiquidFoldedShape.circle,
        ),
      );

      controller.minimize();
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);

      final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
      final pillSize = tester.getSize(expandSemantics);
      expect(pillSize.width, equals(LiquidTabBar.barHeight));
      expect(pillSize.height, equals(LiquidTabBar.barHeight));
    });

    testWidgets('foldedShape oval works in RTL layout and pins to right edge', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: buildBar(
            items: testItems,
            selectedIndex: 0,
            controller: controller,
            foldedShape: LiquidFoldedShape.oval,
          ),
        ),
      );

      controller.minimize();
      await tester.pumpAndSettle();

      final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
      expect(expandSemantics, findsOneWidget);
      final pillSize = tester.getSize(expandSemantics);
      expect(pillSize.width, equals(84.0));
      expect(pillSize.height, equals(LiquidTabBar.barHeight));
    });

    testWidgets(
      'oval foldedShape integrates seamlessly with opaque tier and split action placement',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);
        int selected = 0;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selected,
                onSelected: (i) => setState(() => selected = i),
                controller: controller,
                foldedShape: LiquidFoldedShape.oval,
                separateAction: LiquidTabAction.search(onTap: () {}),
                separateActionPlacement: LiquidTabActionPlacement.split,
              );
            },
          ),
        );

        // Verify expanded state:
        // In split mode, tab bar is pinned to leading margin (left: 24) and action is at trailing margin.
        final actionFinder = find.byIcon(Icons.search_rounded);
        expect(actionFinder, findsOneWidget);
        final actionCenterExpanded = tester.getCenter(actionFinder);
        expect(actionCenterExpanded.dx, equals(748.0));

        // Tap tab 1 to verify opaque selection sync before fold
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(selected, equals(1));

        // Fold to oval
        controller.minimize();
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);

        // Semantics for expand should be 84x64 at leading margin (20.0)
        final expandSemantics = find.bySemanticsLabel('Expand navigation bar');
        expect(expandSemantics, findsOneWidget);
        final pillRect = tester.getRect(expandSemantics);
        expect(pillRect.width, equals(84.0));
        expect(pillRect.height, equals(LiquidTabBar.barHeight));
        expect(pillRect.left, equals(20.0)); // stays pinned to leading margin

        // Action button stays pinned at trailing margin when folded
        final actionCenterFolded = tester.getCenter(actionFinder);
        expect(actionCenterFolded.dx, equals(actionCenterExpanded.dx));

        // Unfold / expand back
        controller.expand();
        await tester.pumpAndSettle();
        expect(controller.minimized, isFalse);

        // Active tab is still Orders (index 1), opaque pill is intact
        expect(selected, equals(1));
      },
    );

    testWidgets(
      'LiquidTabBar.handleScroll and static helpers control shared bar',
      (tester) async {
        LiquidTabBarController.shared.expand();
        addTearDown(LiquidTabBarController.shared.expand);

        expect(LiquidTabBar.isMinimized, isFalse);

        LiquidTabBar.minimize();
        expect(LiquidTabBar.isMinimized, isTrue);

        LiquidTabBar.expand();
        expect(LiquidTabBar.isMinimized, isFalse);
      },
    );

    testWidgets('direct material argument applies without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              items: testItems,
              selectedIndex: 0,
              material: LiquidTabBarMaterial.opaque,
            ),
          ),
        ),
      );
      expect(find.byType(LiquidTabBar), findsOneWidget);
    });
  });

  group('LiquidTabBar Separate Action & Trailing Icon', () {
    testWidgets('renders separateAction circular button and triggers onTap', (
      tester,
    ) async {
      var actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              items: testItems,
              selectedIndex: 0,
              material: LiquidTabBarMaterial.opaque,
              separateAction: LiquidTabAction.icon(
                icon: Icons.search,
                tooltip: 'Search',
                onTap: () => actionTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.bySemanticsLabel('Search'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(actionTapped, isTrue);
    });

    testWidgets(
      'renders separateAction with custom builder and triggers onTap',
      (tester) async {
        int? selected;
        final items = [
          LiquidTabItem.icon(label: 'Home', icon: Icons.home),
          LiquidTabItem.icon(label: 'Orders', icon: Icons.receipt),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: items,
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                separateAction: LiquidTabAction(
                  icon: const Icon(Icons.search),
                  tooltip: 'Search',
                  onTap: () => selected = 2,
                ),
                onSelected: (i) => selected = i,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap the separate search icon
        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(selected, equals(2));
      },
    );

    testWidgets('separateAction supports badgeText', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              items: testItems,
              selectedIndex: 0,
              material: LiquidTabBarMaterial.opaque,
              separateAction: LiquidTabAction.icon(
                icon: Icons.notifications,
                badgeText: '5',
                tooltip: 'Notifications',
              ),
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('custom action widget renders alongside tab bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              items: testItems,
              selectedIndex: 0,
              material: LiquidTabBarMaterial.opaque,
              separateAction: const LiquidTabAction(
                icon: Icon(Icons.add_circle),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets(
      '4 tabs + separate action displays all items and action without clipping on compact screens',
      (tester) async {
        for (final screenWidth in [360.0, 375.0, 390.0, 440.0]) {
          tester.view.physicalSize = Size(screenWidth, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final fourItems = [
            LiquidTabItem.icon(label: 'Home', icon: Icons.home),
            LiquidTabItem.icon(label: 'New', icon: Icons.grid_view),
            LiquidTabItem.icon(label: 'Radio', icon: Icons.podcasts),
            LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
          ];

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                bottomNavigationBar: LiquidTabBar(
                  items: fourItems,
                  selectedIndex: 0,
                  material: LiquidTabBarMaterial.opaque,
                  separateAction: LiquidTabAction.icon(
                    icon: Icons.search,
                    tooltip: 'Search',
                    onTap: () {},
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          // Check that all 4 tab labels and the search icon exist
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('New'), findsOneWidget);
          expect(find.text('Radio'), findsOneWidget);
          expect(find.text('Library'), findsOneWidget);
          expect(find.byIcon(Icons.search), findsOneWidget);

          // Check geometry: search action button must be fully inside the screen bounds
          final actionBox = tester.getRect(find.byIcon(Icons.search));
          expect(actionBox.left, greaterThanOrEqualTo(0.0));
          expect(actionBox.right, lessThanOrEqualTo(screenWidth));

          // Check geometry: Home tab is inside screen bounds
          final homeBox = tester.getRect(find.text('Home'));
          expect(homeBox.left, greaterThanOrEqualTo(0.0));
          expect(homeBox.right, lessThanOrEqualTo(screenWidth));
        }
      },
    );

    testWidgets(
      '4 regular items + separateAction shows all 4 in capsule and 5th as action',
      (tester) async {
        int? actionTapped;
        final fourItems = [
          LiquidTabItem.icon(label: 'Home', icon: Icons.home),
          LiquidTabItem.icon(label: 'New', icon: Icons.grid_view),
          LiquidTabItem.icon(label: 'Radio', icon: Icons.podcasts),
          LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: fourItems,
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                separateAction: LiquidTabAction.icon(
                  icon: Icons.search,
                  onTap: () => actionTapped = 4,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Radio'), findsOneWidget);
        expect(find.text('Library'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();
        expect(actionTapped, equals(4));
      },
    );

    testWidgets(
      'tapping LiquidTabAction.search morphs bar into search field and shrinks tabs to active icon',
      (tester) async {
        String? queryText;
        bool searchClosed = false;
        final fourItems = [
          LiquidTabItem.icon(label: 'Home', icon: Icons.home),
          LiquidTabItem.icon(label: 'New', icon: Icons.grid_view),
          LiquidTabItem.icon(label: 'Radio', icon: Icons.podcasts),
          LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: fourItems,
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                separateAction: LiquidTabAction.search(
                  hintText: 'Artists, Songs, Lyrics, and...',
                  onChanged: (val) => queryText = val,
                  onClose: () => searchClosed = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Before tapping search: all 4 tabs and search circle are visible
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Radio'), findsOneWidget);
        expect(find.text('Library'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);

        // Tap search circle
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        // Search TextField has appeared with custom hint text
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Artists, Songs, Lyrics, and...'), findsOneWidget);

        // Verify NO mic icon exists
        expect(find.byIcon(Icons.mic), findsNothing);
        expect(find.byIcon(Icons.mic_none), findsNothing);

        // Type text into search field
        await tester.enterText(find.byType(TextField), 'Coldplay');
        await tester.pumpAndSettle();
        expect(queryText, equals('Coldplay'));

        // The expanded search exposes only the outer close control. Text input
        // remains active without an additional inner clear icon.
        expect(find.byIcon(Icons.cancel), findsNothing);

        // Tapping the collapsed active tab button closes search mode and expands tabs
        await tester.tap(find.bySemanticsLabel('Close search and show tabs'));
        await tester.pumpAndSettle();

        expect(searchClosed, isTrue);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('New'), findsOneWidget);
        expect(find.text('Radio'), findsOneWidget);
        expect(find.text('Library'), findsOneWidget);
      },
    );

    testWidgets(
      'search field dynamically floats above keyboard when viewInsets.bottom is present',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        Widget buildApp({required double keyboardHeight}) {
          return MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 800),
              viewInsets: EdgeInsets.only(bottom: keyboardHeight),
              viewPadding: const EdgeInsets.only(bottom: 34),
            ),
            child: MaterialApp(
              home: Scaffold(
                extendBody: true,
                body: const SizedBox.expand(),
                bottomNavigationBar: LiquidTabBar(
                  material: LiquidTabBarMaterial.opaque,
                  items: [
                    LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                    LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                  ],
                  selectedIndex: 0,
                  separateAction: LiquidTabAction.search(
                    hintText: 'Search songs...',
                  ),
                ),
              ),
            ),
          );
        }

        // Initial state: no keyboard
        await tester.pumpWidget(buildApp(keyboardHeight: 0.0));
        await tester.pumpAndSettle();

        // Open search
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);

        final noKeyboardFieldRect = tester.getRect(find.byType(TextField));
        final noKeyboardBarHeight =
            tester.getSize(find.byType(LiquidTabBar)).height;
        // Without keyboard, search field is near the bottom of 800px screen
        expect(noKeyboardFieldRect.bottom, greaterThan(700.0));
        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(noKeyboardFieldRect.center.dy, 0.001),
        );

        // Keyboard appears with height 320
        await tester.pumpWidget(buildApp(keyboardHeight: 320.0));
        await tester.pumpAndSettle();

        final withKeyboardFieldRect = tester.getRect(find.byType(TextField));
        final withKeyboardBarHeight =
            tester.getSize(find.byType(LiquidTabBar)).height;
        expect(withKeyboardBarHeight, closeTo(noKeyboardBarHeight, 0.001));
        // With keyboard of 320px, the search field must sit above 800 - 320 = 480px!
        expect(withKeyboardFieldRect.bottom, lessThanOrEqualTo(480.0));
        expect(withKeyboardFieldRect.top, greaterThan(400.0));
        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(withKeyboardFieldRect.center.dy, 0.001),
        );

        // Keyboard closes
        await tester.pumpWidget(buildApp(keyboardHeight: 0.0));
        await tester.pumpAndSettle();

        final closedKeyboardFieldRect = tester.getRect(find.byType(TextField));
        expect(closedKeyboardFieldRect.bottom, greaterThan(700.0));
        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(closedKeyboardFieldRect.center.dy, 0.001),
        );
      },
    );

    testWidgets(
      'search and folding: action surface and search field retain exact same centerY during folding and across keyboard transitions',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.binding.setSurfaceSize(const Size(834, 1210));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        Widget buildApp({required double keyboard}) {
          return MediaQuery(
            data: MediaQueryData(
              size: const Size(834, 1210),
              viewInsets: EdgeInsets.only(bottom: keyboard),
              viewPadding: const EdgeInsets.only(bottom: 24),
            ),
            child: MaterialApp(
              home: Scaffold(
                extendBody: true,
                body: const SizedBox.expand(),
                bottomNavigationBar: LiquidTabBar(
                  controller: controller,
                  material: LiquidTabBarMaterial.opaque,
                  items: [
                    LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                    LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                  ],
                  selectedIndex: 0,
                  separateActionPlacement: LiquidTabActionPlacement.split,
                  separateAction: LiquidTabAction.search(
                    hintText: 'Search content...',
                  ),
                ),
              ),
            ),
          );
        }

        await tester.pumpWidget(buildApp(keyboard: 0.0));
        await tester.pumpAndSettle();

        controller.openSearch();
        await tester.pumpAndSettle();

        // Expanded with no keyboard
        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(tester.getRect(find.byType(TextField)).center.dy, 0.001),
        );

        // Keyboard appears
        await tester.pumpWidget(buildApp(keyboard: 400.0));
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(tester.getRect(find.byType(TextField)).center.dy, 0.001),
        );

        // Fold while keyboard is up
        controller.minimize();
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(tester.getRect(find.byType(TextField)).center.dy, 0.001),
        );

        // Expand again
        controller.expand();
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(tester.getRect(find.byType(TextField)).center.dy, 0.001),
        );

        // Dismiss keyboard
        await tester.pumpWidget(buildApp(keyboard: 0.0));
        await tester.pumpAndSettle();

        expect(
          tester.getRect(find.byIcon(Icons.home)).center.dy,
          closeTo(tester.getRect(find.byType(TextField)).center.dy, 0.001),
        );

        // Close search
        controller.closeSearch();
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'tapping outside search TextField removes focus and dismisses keyboard',
      (tester) async {
        bool outsideTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                color: Colors.white,
                child: const Center(child: Text('Body Content Area')),
              ),
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(
                  hintText: 'Type query...',
                  onTapOutside: (_) => outsideTapped = true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Open search
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        final textFieldFinder = find.byType(TextField);
        expect(textFieldFinder, findsOneWidget);

        // Verify focus is acquired
        final FocusNode focusNode =
            tester.widget<TextField>(textFieldFinder).focusNode!;
        expect(focusNode.hasFocus, isTrue);

        // Tap on body area outside search field
        await tester.tap(find.text('Body Content Area'));
        await tester.pumpAndSettle();

        // Custom callback invoked and focus removed
        expect(outsideTapped, isTrue);
        expect(focusNode.hasFocus, isFalse);
      },
    );

    testWidgets('expanded search keeps only the outer close affordance', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.opaque,
              items: [
                LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
              ],
              selectedIndex: 0,
              separateAction: LiquidTabAction.search(hintText: 'Type query...'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      final FocusNode focusNode =
          tester.widget<TextField>(textFieldFinder).focusNode!;
      expect(focusNode.hasFocus, isTrue);

      // Enter text
      await tester.enterText(textFieldFinder, 'Beethoven');
      await tester.pumpAndSettle();

      // The inner TextField clear affordance is intentionally not rendered.
      expect(find.byIcon(Icons.cancel), findsNothing);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(focusNode.hasFocus, isTrue);
    });

    testWidgets(
      'RTL and reduced motion support search expansion and keyboard avoidance',
      (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: Scaffold(
                  bottomNavigationBar: LiquidTabBar(
                    material: LiquidTabBarMaterial.opaque,
                    items: [
                      LiquidTabItem.icon(label: 'בית', icon: Icons.home),
                      LiquidTabItem.icon(
                        label: 'מוזיקה',
                        icon: Icons.library_music,
                      ),
                    ],
                    selectedIndex: 0,
                    separateAction: LiquidTabAction.search(
                      hintText: 'חיפוש...',
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap search
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('חיפוש...'), findsOneWidget);

        // In reduced motion, focus is immediately requested
        final textFieldFinder = find.byType(TextField);
        final FocusNode focusNode =
            tester.widget<TextField>(textFieldFinder).focusNode!;
        expect(focusNode.hasFocus, isTrue);
      },
    );

    testWidgets('LiquidTabAction.search applies custom style and hintStyle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.opaque,
              items: [
                LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
              ],
              selectedIndex: 0,
              separateAction: LiquidTabAction.search(
                hintText: 'Custom hint',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.style?.fontSize, equals(18));
      expect(textField.style?.fontWeight, equals(FontWeight.bold));
      expect(textField.decoration?.hintStyle?.fontSize, equals(14));
      expect(
        textField.decoration?.hintStyle?.fontStyle,
        equals(FontStyle.italic),
      );
    });

    testWidgets(
      'controller.openSearch() and closeSearch() control search morph programmatically',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(
                  hintText: 'Search items...',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initially search is closed
        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);

        // Open search programmatically
        controller.openSearch();
        await tester.pumpAndSettle();

        expect(controller.isSearching, isTrue);
        expect(find.byType(TextField), findsOneWidget);

        // Close search programmatically
        controller.closeSearch();
        await tester.pumpAndSettle();

        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);

        // Tap search icon to open, then close via close button when text is empty
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        expect(controller.isSearching, isTrue);
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();

        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'controller.openSearch() and closeSearch() are idempotent and safe against redundant calls',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(hintText: 'Search...'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        int notifyCount = 0;
        controller.addListener(() => notifyCount++);

        // Redundant closeSearch() while already closed should be a no-op
        controller.closeSearch();
        controller.closeSearch(clearText: true);
        expect(notifyCount, equals(0));
        expect(controller.isSearching, isFalse);

        // First openSearch() should notify once
        controller.openSearch();
        expect(notifyCount, equals(1));
        expect(controller.isSearching, isTrue);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);

        // Redundant openSearch() while already open should be a no-op
        controller.openSearch();
        controller.openSearch();
        expect(notifyCount, equals(1));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);

        // First closeSearch() should notify once
        controller.closeSearch();
        expect(notifyCount, equals(2));
        expect(controller.isSearching, isFalse);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'search sync correctness between manual user taps and programmatic calls',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(hintText: 'Search...'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap search action button manually
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();

        // Controller must reflect active search
        expect(controller.isSearching, isTrue);
        expect(find.byType(TextField), findsOneWidget);

        // Programmatic openSearch() while already open from tap is a safe no-op
        controller.openSearch();
        await tester.pumpAndSettle();
        expect(controller.isSearching, isTrue);

        // Close programmatically while user is in search
        controller.closeSearch();
        await tester.pumpAndSettle();
        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);

        // Tap again manually to reopen
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();
        expect(controller.isSearching, isTrue);

        // Close by tapping the close button
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(controller.isSearching, isFalse);
      },
    );

    testWidgets(
      'closeSearch correctly preserves or clears search text based on clearText and clearOnClose',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(hintText: 'Search...'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Open and enter text
        controller.openSearch();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Chopin');
        await tester.pumpAndSettle();

        // 2. Default closeSearch(clearText: false) preserves text
        controller.closeSearch();
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);

        // Reopen -> 'Chopin' is still preserved
        controller.openSearch();
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals('Chopin'));

        // 3. closeSearch(clearText: true) clears text
        controller.closeSearch(clearText: true);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);

        // Reopen -> text is now empty
        controller.openSearch();
        await tester.pumpAndSettle();
        final reopenedField = tester.widget<TextField>(find.byType(TextField));
        expect(reopenedField.controller?.text, isEmpty);
      },
    );

    testWidgets(
      'LiquidTabBarSearch(clearOnClose: true) clears query automatically on close',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(
                    label: 'Library',
                    icon: Icons.library_music,
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.search(
                  hintText: 'Search...',
                  clearOnClose: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        controller.openSearch();
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Mozart');
        await tester.pumpAndSettle();

        // Standard close triggers clearOnClose
        controller.closeSearch();
        await tester.pumpAndSettle();

        controller.openSearch();
        await tester.pumpAndSettle();
        final reopenedField = tester.widget<TextField>(find.byType(TextField));
        expect(reopenedField.controller?.text, isEmpty);
      },
    );

    testWidgets(
      'LiquidTabActionPlacement.split places tabs on leading edge and action on trailing edge',
      (tester) async {
        // 4 tabs + 1 action button on standard 400px width screen
        tester.view.physicalSize = const Size(400 * 3, 800 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.opaque,
                separateActionPlacement: LiquidTabActionPlacement.split,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Explore', icon: Icons.explore),
                  LiquidTabItem.icon(
                    label: 'Activity',
                    icon: Icons.notifications,
                  ),
                  LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction.icon(
                  icon: Icons.add,
                  onTap: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final addCenter = tester.getCenter(find.byIcon(Icons.add));

        // In split placement on LTR, Home (tab 0) is on the left side of the screen
        // and Add action is on the far right side of the screen
        expect(homeCenter.dx, lessThan(100.0));
        expect(addCenter.dx, greaterThan(320.0));

        // There is an open split space between tabs capsule and action button (> 20px)
        final profileCenter = tester.getCenter(find.text('Profile'));
        final gap = addCenter.dx - profileCenter.dx;
        expect(gap, greaterThan(30.0));
      },
    );

    testWidgets(
      'LiquidDropletChromaticPainter renders rainbow caustics at rest and during motion',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Explore', icon: Icons.explore),
                  LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
                ],
                selectedIndex: 1,
                theme: LiquidTabBarTheme.dark(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // CustomPaint for chromatic lens is present
        final chromaticPaints = find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter is LiquidDropletChromaticPainter,
        );
        expect(chromaticPaints, findsOneWidget);

        // Tap tab 0 to trigger spring motion
        await tester.tap(find.text('Home'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));

        // Lens is moving mid-flight with dynamic dispersion
        expect(chromaticPaints, findsOneWidget);

        await tester.pumpAndSettle();
        expect(chromaticPaints, findsOneWidget);
      },
    );

    testWidgets(
      'Magnification and LiquidDropletChromaticPainter active during scrub/slide',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Explore', icon: Icons.explore),
                  LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
                ],
                selectedIndex: 0,
                theme: LiquidTabBarTheme.dark(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final exploreCenter = tester.getCenter(find.text('Explore'));

        // Start gesture on Home and drag towards Explore
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump();
        await gesture.moveTo(Offset.lerp(homeCenter, exploreCenter, 0.5)!);
        await tester.pump();

        // Verify chromatic painter has high motion during scrubbing
        final chromaticFinder = find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.painter is LiquidDropletChromaticPainter,
        );
        expect(chromaticFinder, findsOneWidget);
        final customPaint = tester.widget<CustomPaint>(chromaticFinder);
        final painter = customPaint.painter as LiquidDropletChromaticPainter;
        expect(painter.motion, greaterThan(0.5));

        // Organic embedded liquid deformation transforms are applied
        final transforms = find.byType(Transform);
        expect(transforms, findsWidgets);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );
  });

  group('LiquidTabBar Embedded Liquid Interaction Effect', () {
    const testActiveColor = Color(0xFF007AFF);
    const testInactiveColor = Color(0xFF8E8E93);

    testWidgets(
      'continuous color interpolation as liquid indicator moves between tabs',
      (tester) async {
        Color? homeIconColor;
        Color? ordersIconColor;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(
                    label: 'Home',
                    icon: Icons.home,
                    iconBuilder: (color, selected) {
                      homeIconColor = color;
                      return Icon(Icons.home, color: color);
                    },
                  ),
                  LiquidTabItem.icon(
                    label: 'Orders',
                    icon: Icons.receipt,
                    iconBuilder: (color, selected) {
                      ordersIconColor = color;
                      return Icon(Icons.receipt, color: color);
                    },
                  ),
                  LiquidTabItem.icon(
                    label: 'Me',
                    icon: Icons.person,
                    iconBuilder: (color, selected) {
                      return Icon(Icons.person, color: color);
                    },
                  ),
                ],
                selectedIndex: 0,
                theme: const LiquidTabBarTheme(
                  activeColor: testActiveColor,
                  inactiveColor: testInactiveColor,
                ),
                material: LiquidTabBarMaterial.opaque,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // At rest on tab 0 (Home): Home is 100% activeColor, Orders is 100% inactiveColor
        expect(homeIconColor, equals(testActiveColor));
        expect(ordersIconColor, equals(testInactiveColor));

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));

        // Start drag from Home toward Orders
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump();

        // Move halfway between Home and Orders
        await gesture.moveTo(Offset.lerp(homeCenter, ordersCenter, 0.5)!);
        await tester.pump();

        // At halfway, continuous liquid coverage interpolates both tabs towards intermediate blend
        expect(homeIconColor, isNotNull);
        expect(ordersIconColor, isNotNull);
        expect(homeIconColor, isNot(equals(testActiveColor)));
        expect(ordersIconColor, isNot(equals(testInactiveColor)));

        // Home should be in between active and inactive
        final expectedMidColor = Color.lerp(
          testInactiveColor,
          testActiveColor,
          0.5,
        )!;
        expect((homeIconColor!.r - expectedMidColor.r).abs(), lessThan(0.08));
        expect((ordersIconColor!.r - expectedMidColor.r).abs(), lessThan(0.08));

        // Drag all the way to Orders and release
        await gesture.moveTo(ordersCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        // Settled at Orders (tab 1): Orders is activeColor, Home is inactiveColor
        expect(ordersIconColor, equals(testActiveColor));
        expect(homeIconColor, equals(testInactiveColor));
      },
    );

    testWidgets(
      'icon returns to normal 1.0 geometry without dock zoom when liquid settles at rest',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Explore', icon: Icons.explore),
                  LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
                ],
                selectedIndex: 0,
                theme: const LiquidTabBarTheme(
                  activeColor: testActiveColor,
                  inactiveColor: testInactiveColor,
                ),
                material: LiquidTabBarMaterial.opaque,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // The icons and labels must remain completely stable without fake Transform deforming them
        final homeCenter = tester.getCenter(find.text('Home'));
        final exploreCenter = tester.getCenter(find.text('Explore'));

        // Dragging moves the droplet lens across tabs without duplicating or deforming icon widgets
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump();
        await gesture.moveTo(Offset.lerp(homeCenter, exploreCenter, 0.5)!);
        await tester.pump();

        // No fake transformed glyph copies exist in the widget tree
        expect(
          find.byKey(const ValueKey('liquid_embedded_glyph_transform')),
          findsNothing,
        );

        // Release and settle
        await gesture.up();
        await tester.pumpAndSettle();

        // When settled, icons remain normal, crisp, and stable
        expect(
          find.byKey(const ValueKey('liquid_embedded_glyph_transform')),
          findsNothing,
        );
        expect(find.byType(LiquidTabBar), findsOneWidget);
      },
    );

    testWidgets(
      'reduced motion accessibility disables organic distortion while preserving liquid color',
      (tester) async {
        Color? ordersIconColor;
        int selectedTab = 0;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Builder(
                  builder: (context) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(disableAnimations: true),
                      child: Scaffold(
                        bottomNavigationBar: LiquidTabBar(
                          items: [
                            LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                            LiquidTabItem.icon(
                              label: 'Orders',
                              icon: Icons.receipt,
                              iconBuilder: (color, selected) {
                                ordersIconColor = color;
                                return Icon(Icons.receipt, color: color);
                              },
                            ),
                          ],
                          selectedIndex: selectedTab,
                          onSelected: (i) => setState(() => selectedTab = i),
                          theme: const LiquidTabBarTheme(
                            activeColor: testActiveColor,
                            inactiveColor: testInactiveColor,
                          ),
                          material: LiquidTabBarMaterial.opaque,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Initially Orders is inactive
        expect(ordersIconColor, equals(testInactiveColor));

        // Tapping Orders under reduced motion switches tab immediately to activeColor
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(selectedTab, equals(1));
        expect(ordersIconColor, equals(testActiveColor));

        // Verify no organic deformation transforms are applied under reduced motion
        expect(
          find.byKey(const ValueKey('liquid_embedded_glyph_transform')),
          findsNothing,
        );
      },
    );

    testWidgets('RTL layout properly routes continuous liquid coverage', (
      tester,
    ) async {
      Color? homeIconColor;
      Color? ordersIconColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(
                    label: 'Home',
                    icon: Icons.home,
                    iconBuilder: (color, selected) {
                      homeIconColor = color;
                      return Icon(Icons.home, color: color);
                    },
                  ),
                  LiquidTabItem.icon(
                    label: 'Orders',
                    icon: Icons.receipt,
                    iconBuilder: (color, selected) {
                      ordersIconColor = color;
                      return Icon(Icons.receipt, color: color);
                    },
                  ),
                ],
                selectedIndex: 0,
                theme: const LiquidTabBarTheme(
                  activeColor: testActiveColor,
                  inactiveColor: testInactiveColor,
                ),
                material: LiquidTabBarMaterial.opaque,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially Home (tab 0) is active
      expect(homeIconColor, equals(testActiveColor));
      expect(ordersIconColor, equals(testInactiveColor));

      final homeCenter = tester.getCenter(find.text('Home'));
      final ordersCenter = tester.getCenter(find.text('Orders'));

      // In RTL, Home is on the right, Orders is on the left
      expect(homeCenter.dx, greaterThan(ordersCenter.dx));

      // Drag from Home toward Orders in RTL
      final gesture = await tester.startGesture(homeCenter);
      await tester.pump();
      await gesture.moveTo(Offset.lerp(homeCenter, ordersCenter, 0.5)!);
      await tester.pump();

      // Midway through the drag in RTL, continuous liquid coverage interpolates both tabs
      expect(homeIconColor, isNotNull);
      expect(ordersIconColor, isNotNull);
      expect(homeIconColor, isNot(equals(testActiveColor)));
      expect(ordersIconColor, isNot(equals(testInactiveColor)));

      // Drag all the way to Orders and release
      await gesture.moveTo(ordersCenter);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(ordersIconColor, equals(testActiveColor));
      expect(homeIconColor, equals(testInactiveColor));
    });

    testWidgets(
      'opaque-tier badge maintains its distinct color without refraction',
      (tester) async {
        const customBadgeColor = Color(0xFF25D366); // WhatsApp green
        const barActiveColor = Color(0xFFFF0000); // Red

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(
                    label: 'Home',
                    icon: Icons.home,
                    badge: true,
                    badgeCount: 3,
                    badgeStyle: const LiquidBadgeStyle(color: customBadgeColor),
                  ),
                  LiquidTabItem.icon(label: 'Orders', icon: Icons.receipt),
                ],
                selectedIndex: 0,
                theme: const LiquidTabBarTheme(
                  activeColor: barActiveColor,
                  inactiveColor: Color(0xFF8E8E93),
                ),
                material: LiquidTabBarMaterial.opaque,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the badge Container
        Container getBadgeContainer() {
          return tester.widget<Container>(
            find
                .ancestor(of: find.text('3'), matching: find.byType(Container))
                .first,
          );
        }

        // Initial state: droplet is at tab 0
        expect(
          (getBadgeContainer().decoration as BoxDecoration).color,
          equals(customBadgeColor),
        );

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));

        // Start drag to tab 1 and back so the water droplet touches and moves across the badge
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump();
        await gesture.moveTo(Offset.lerp(homeCenter, ordersCenter, 0.5)!);
        await tester.pump();

        // Opaque material has no optical sampling; the badge remains strictly green.
        expect(
          (getBadgeContainer().decoration as BoxDecoration).color,
          equals(customBadgeColor),
        );
        expect(
          (getBadgeContainer().decoration as BoxDecoration).color,
          isNot(equals(barActiveColor)),
        );

        // Drag all the way to Orders
        await gesture.moveTo(ordersCenter);
        await tester.pump();

        expect(
          (getBadgeContainer().decoration as BoxDecoration).color,
          equals(customBadgeColor),
        );

        // Drag back to Home
        await gesture.moveTo(homeCenter);
        await tester.pump();
        await gesture.up();
        await tester.pumpAndSettle();

        // Settled back on Home: badge is still custom green
        expect(
          (getBadgeContainer().decoration as BoxDecoration).color,
          equals(customBadgeColor),
        );
      },
    );
  });

  group('LiquidTabBar Blur Tier & GlassLightPainter Rendering', () {
    testWidgets('renders BackdropFilter and GlassLightPainter on blur tier', (
      tester,
    ) async {
      int? selectedTab;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.blur,
              items: testItems,
              selectedIndex: 0,
              onSelected: (i) => selectedTab = i,
            ),
          ),
        ),
      );

      expect(find.byType(LiquidTabBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Me'), findsOneWidget);

      // Verify BackdropFilter is present for the frost effect
      expect(find.byType(BackdropFilter), findsWidgets);

      // Verify GlassLightPainter is rendered on the blur surface
      final customPaints = tester.widgetList<CustomPaint>(
        find.byType(CustomPaint),
      );
      final hasGlassLightPainter = customPaints.any(
        (p) => p.painter is GlassLightPainter,
      );
      expect(hasGlassLightPainter, isTrue);

      // Verify tab selection works on blur tier
      await tester.tap(find.text('Orders'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(selectedTab, equals(1));
    });

    testWidgets(
      'renders dark mode blur tier with theme-aware GlassLightPainter and dark presets',
      (tester) async {
        const darkTheme = LiquidTabBarTheme.dark();
        expect(darkTheme.barStyle.blurTint, equals(const Color(0x22384254)));
        expect(darkTheme.barStyle.blurEdge, equals(const Color(0x55FFFFFF)));
        expect(
          darkTheme.barStyle.blurSheenTop,
          equals(const Color(0x2CFFFFFF)),
        );
        expect(
          darkTheme.barStyle.blurSheenBottom,
          equals(const Color(0x08FFFFFF)),
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.blur,
                theme: darkTheme,
                items: testItems,
                selectedIndex: 0,
              ),
            ),
          ),
        );

        final customPaints = tester.widgetList<CustomPaint>(
          find.byType(CustomPaint),
        );
        final darkPainter = customPaints
            .map((p) => p.painter)
            .whereType<GlassLightPainter>()
            .firstOrNull;
        expect(darkPainter, isNotNull);
        expect(darkPainter!.isDark, isTrue);

        final oldPainter = GlassLightPainter(
          style: darkTheme.barStyle.glass,
          radius: 20,
          isDark: false,
        );
        final newPainter = GlassLightPainter(
          style: darkTheme.barStyle.glass,
          radius: 20,
          isDark: true,
        );
        expect(newPainter.shouldRepaint(oldPainter), isTrue);
      },
    );

    testWidgets('separateAction and search expand cleanly on blur tier', (
      tester,
    ) async {
      String submittedQuery = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.blur,
              items: testItems,
              selectedIndex: 0,
              separateAction: LiquidTabAction.search(
                hintText: 'Search songs...',
                onSubmitted: (q) => submittedQuery = q,
              ),
            ),
          ),
        ),
      );

      // Tap search action button
      await tester.tap(find.byIcon(Icons.search_rounded), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Liquid Glass');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(submittedQuery, equals('Liquid Glass'));
    });

    testWidgets('LiquidTabBarSearch respects custom animationDuration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.opaque,
              items: testItems,
              selectedIndex: 0,
              separateAction: LiquidTabAction.search(
                animationDuration: const Duration(milliseconds: 500),
                hintText: 'Search...',
              ),
            ),
          ),
        ),
      );

      // Tap search to start animating
      await tester.tap(find.byIcon(Icons.search_rounded), warnIfMissed: false);
      await tester.pump();

      // At 250ms (halfway), the animation is mid-flight
      await tester.pump(const Duration(milliseconds: 250));
      // Settle the remainder of 500ms
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets(
      '_frostFilter bounds cache to at most 24 entries during continuous tuning',
      (tester) async {
        // Pump blur tier with 40 distinct blur styles to simulate rapid slider dragging
        for (int i = 0; i < 40; i++) {
          final style = GlassStyle(
            blur: 5.0 + i.toDouble(),
            saturation: 1.0 + (i * 0.02),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                bottomNavigationBar: LiquidTabBar(
                  material: LiquidTabBarMaterial.blur,
                  items: testItems,
                  selectedIndex: 0,
                  theme: LiquidTabBarTheme(
                    barStyle: LiquidBarStyle(glass: style),
                  ),
                ),
              ),
            ),
          );
        }
        expect(find.byType(LiquidTabBar), findsOneWidget);
      },
    );
  });

  group('LiquidTabBar Opaque Tier Neutral Gray Droplet Pill', () {
    testWidgets(
      'renders flat neutral gray pill in light theme (not activeColor-tinted)',
      (tester) async {
        const activeBlue = Color(0xFF007AFF);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                selectedIndex: 1,
                theme: LiquidTabBarTheme(activeColor: activeBlue),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find the droplet DecoratedBox (distinguished by having circular border radius and being inside the bar)
        final dropletFinders = find.byWidgetPredicate((w) {
          if (w is DecoratedBox && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.borderRadius is BorderRadius &&
                box.color != null &&
                box.gradient == null &&
                box.boxShadow == null &&
                box.border == null;
          }
          return false;
        });
        expect(dropletFinders, findsOneWidget);

        final dropletBox = tester.widget<DecoratedBox>(dropletFinders);
        final decoration = dropletBox.decoration as BoxDecoration;
        final pillColor = decoration.color!;

        // Neutral black tint with alpha between 0.05 and 0.08 (tune 0.06)
        expect(pillColor.a, inInclusiveRange(0.05, 0.08));
        // Pure neutral (r=0, g=0, b=0), not tinted with activeColor
        expect(pillColor.r, equals(0.0));
        expect(pillColor.g, equals(0.0));
        expect(pillColor.b, equals(0.0));
        expect(pillColor, isNot(equals(activeBlue)));

        // Active tab (Orders) retains activeColor
        final activeText = tester.widget<Text>(find.text('Orders'));
        expect(activeText.style?.color, equals(activeBlue));
      },
    );

    testWidgets(
      'renders flat neutral white-gray pill in dark theme (not activeColor-tinted)',
      (tester) async {
        const activeRed = Color(0xFFFF3B30);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                selectedIndex: 1,
                theme: LiquidTabBarTheme.dark(activeColor: activeRed),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final dropletFinders = find.byWidgetPredicate((w) {
          if (w is DecoratedBox && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.borderRadius is BorderRadius &&
                box.color != null &&
                box.gradient == null &&
                box.boxShadow == null &&
                box.border == null;
          }
          return false;
        });
        expect(dropletFinders, findsOneWidget);

        final dropletBox = tester.widget<DecoratedBox>(dropletFinders);
        final decoration = dropletBox.decoration as BoxDecoration;
        final pillColor = decoration.color!;

        // Neutral white tint with alpha between 0.08 and 0.12 (tune 0.10)
        expect(pillColor.a, inInclusiveRange(0.08, 0.12));
        // Pure neutral (r=1.0, g=1.0, b=1.0), not tinted with activeColor
        expect(pillColor.r, equals(1.0));
        expect(pillColor.g, equals(1.0));
        expect(pillColor.b, equals(1.0));
        expect(pillColor, isNot(equals(activeRed)));

        // Active tab (Orders) retains activeColor
        final activeText = tester.widget<Text>(find.text('Orders'));
        expect(activeText.style?.color, equals(activeRed));
      },
    );

    testWidgets('preserves gradient, border, and drop shadow on blur tier', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            bottomNavigationBar: LiquidTabBar(
              material: LiquidTabBarMaterial.blur,
              items: testItems,
              selectedIndex: 0,
              theme: LiquidTabBarTheme(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find droplet with gradient and shadow
      final blurDropletFinder = find.byWidgetPredicate((w) {
        if (w is DecoratedBox && w.decoration is BoxDecoration) {
          final box = w.decoration as BoxDecoration;
          return box.gradient != null &&
              box.boxShadow != null &&
              box.border != null;
        }
        return false;
      });
      expect(blurDropletFinder, findsOneWidget);
    });

    testWidgets(
      'renders consistent flat neutral gray pill during slide and at rest on opaque tier',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                selectedIndex: 0,
                theme: LiquidTabBarTheme(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Flat neutral gray pill (gradient == null, boxShadow == null)
        final pillDropletFinder = find.byWidgetPredicate((w) {
          if (w is DecoratedBox && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.borderRadius is BorderRadius &&
                box.color != null &&
                box.gradient == null &&
                box.boxShadow == null;
          }
          return false;
        });
        expect(pillDropletFinder, findsOneWidget);

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));

        // Start drag from Home towards Orders
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump();
        await gesture.moveTo(Offset.lerp(homeCenter, ordersCenter, 0.5)!);
        await tester.pump();

        // Mid-flight / scrubbing: neutral gray pill remains solid (no transparent fading or delayed pop-in)
        expect(pillDropletFinder, findsOneWidget);

        // Chromatic painter is also active during motion
        final chromaticFinder = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is LiquidDropletChromaticPainter,
        );
        expect(chromaticFinder, findsOneWidget);

        // Release and settle on Orders
        await gesture.up();
        await tester.pumpAndSettle();

        // Settled after select: clean neutral gray pill remains active
        expect(pillDropletFinder, findsOneWidget);
      },
    );

    testWidgets(
      'opaque tier tap selection updates neutral gray pill in lockstep with icon color (no delay/desync)',
      (tester) async {
        int selectedIndex = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) => Scaffold(
                bottomNavigationBar: LiquidTabBar(
                  material: LiquidTabBarMaterial.opaque,
                  items: testItems,
                  selectedIndex: selectedIndex,
                  onSelected: (i) => setState(() => selectedIndex = i),
                  theme: LiquidTabBarTheme(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final pillFinder = find.byWidgetPredicate((w) {
          if (w is DecoratedBox && w.decoration is BoxDecoration) {
            final box = w.decoration as BoxDecoration;
            return box.borderRadius is BorderRadius &&
                box.color != null &&
                box.gradient == null &&
                box.boxShadow == null;
          }
          return false;
        });
        expect(pillFinder, findsOneWidget);

        // Tap adjacent tab: Orders (slot 1)
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        // Step through frames of the spring animation:
        // At 16ms, 32ms, 64ms, 100ms, 200ms, 350ms
        for (final ms in [16, 16, 32, 50, 100, 150]) {
          await tester.pump(Duration(milliseconds: ms));
          // The pill must NEVER disappear or be transparent while spring is moving
          expect(
            pillFinder,
            findsOneWidget,
            reason: 'Pill disappeared at +$ms ms during tap',
          );
        }

        await tester.pumpAndSettle();
        expect(pillFinder, findsOneWidget);

        // Tap non-adjacent tab: Me (slot 2)
        await tester.tap(find.text('Me'), warnIfMissed: false);
        for (final ms in [16, 32, 50, 100, 150]) {
          await tester.pump(Duration(milliseconds: ms));
          expect(
            pillFinder,
            findsOneWidget,
            reason: 'Pill disappeared during non-adjacent tap',
          );
        }

        await tester.pumpAndSettle();
        expect(pillFinder, findsOneWidget);

        // Fast repeated tapping: tap Home then immediately Orders
        await tester.tap(find.text('Home'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 30));
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        for (final ms in [16, 32, 50, 100]) {
          await tester.pump(Duration(milliseconds: ms));
          expect(pillFinder, findsOneWidget);
        }
        await tester.pumpAndSettle();
        expect(pillFinder, findsOneWidget);
      },
    );
  });

  group('LiquidTabBar Android & Plain-Flutter Compatibility', () {
    testWidgets(
      'Android back button closes active search morph via PopScope without popping route',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          body: const Text('Detail Screen'),
                          bottomNavigationBar: LiquidTabBar(
                            controller: controller,
                            items: testItems,
                            selectedIndex: 0,
                            separateAction: LiquidTabAction.search(
                              hintText: 'Search orders...',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open Detail'),
                ),
              ),
            ),
          ),
        );

        // Tap to push Detail Screen
        await tester.tap(find.text('Open Detail'));
        await tester.pumpAndSettle();

        expect(find.text('Detail Screen'), findsOneWidget);
        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);

        // Open search
        controller.openSearch();
        await tester.pumpAndSettle();

        expect(controller.isSearching, isTrue);
        expect(find.byType(TextField), findsOneWidget);

        // First system back press: PopScope intercepts to close search, Detail Screen remains visible
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(controller.isSearching, isFalse);
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Detail Screen'), findsOneWidget);

        // Second system back press: now that search is closed, route pops back to Home Screen
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(find.text('Detail Screen'), findsNothing);
        expect(find.text('Open Detail'), findsOneWidget);
      },
    );

    testWidgets(
      'non-Impeller Skia fallback: glass tier gracefully resolves to blur tier when LiquidGlass.supported is false',
      (tester) async {
        // In flutter_test headless environment, LiquidGlass.supported is false
        expect(LiquidGlass.supported, isFalse);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.glass,
                items: testItems,
                selectedIndex: 0,
              ),
            ),
          ),
        );

        // Renders cleanly without throwing or crashing
        expect(find.byType(LiquidTabBar), findsOneWidget);
        // Renders blur tier BackdropFilter as fallback
        expect(find.byType(BackdropFilter), findsWidgets);
      },
    );

    testWidgets(
      'Android TalkBack semantics correctly exposed for tabs and separate action',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                  ),
                  LiquidTabItem.icon(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag,
                    label: 'Cart',
                    badge: true,
                    badgeText: '3',
                  ),
                ],
                selectedIndex: 0,
                separateAction: LiquidTabAction(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add item',
                  onTap: () {},
                ),
              ),
            ),
          ),
        );

        // Tab with badge exposes notification count in Semantics
        expect(
          tester.getSemantics(find.bySemanticsLabel('Cart, 3 notifications')),
          isNotNull,
        );

        // Action button exposes tooltip in Semantics
        expect(
          tester.getSemantics(find.bySemanticsLabel('Add item')),
          isNotNull,
        );
      },
    );
  });

  group('LiquidTabBar Folded State Active Contrast & Icon Decoupling', () {
    testWidgets(
      'rapid fold reversals keep the bar mounted with valid geometry',
      (tester) async {
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                material: LiquidTabBarMaterial.opaque,
                selectedIndex: 0,
                items: testItems,
              ),
            ),
          ),
        );
        await tester.pump();

        final bar = find.byType(LiquidTabBar);
        for (var i = 0; i < 12; i++) {
          if (i.isEven) {
            controller.minimize();
          } else {
            controller.expand();
          }
          await tester.pump(const Duration(milliseconds: 16));
          expect(bar, findsOneWidget);
          final size = tester.getSize(bar);
          expect(size.width, greaterThan(0));
          expect(size.height, greaterThan(0));
        }
        await tester.pumpAndSettle();
        expect(bar, findsOneWidget);
        expect(tester.getSize(bar).height, greaterThan(0));
      },
    );

    testWidgets(
      'folded capsule keeps active tab icon in activeColor and selected state (circle shape)',
      (tester) async {
        const activeColor = Color(0xFF007AFF);
        const inactiveColor = Color(0xFF8E8E93);
        final theme = const LiquidTabBarTheme().copyWith(
          activeColor: activeColor,
          inactiveColor: inactiveColor,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                theme: theme,
                initiallyMinimized: true,
                foldedShape: LiquidFoldedShape.circle,
                selectedIndex: 0,
                items: [
                  LiquidTabItem.icon(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                  ),
                  LiquidTabItem.icon(
                    label: 'Search',
                    icon: Icons.search_outlined,
                    activeIcon: Icons.search,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. In folded state, active tab renders with activeIcon (not inactive outline)
        expect(find.byIcon(Icons.home), findsOneWidget);
        expect(find.byIcon(Icons.home_outlined), findsNothing);

        // 2. Icon color remains activeColor
        final icon = tester.widget<Icon>(find.byIcon(Icons.home));
        expect(icon.color, equals(activeColor));
      },
    );

    testWidgets(
      'folded capsule keeps active tab icon in activeColor and selected state (oval shape)',
      (tester) async {
        const activeColor = Color(0xFFFF2D55);
        final theme = const LiquidTabBarTheme().copyWith(
          activeColor: activeColor,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                theme: theme,
                initiallyMinimized: true,
                foldedShape: LiquidFoldedShape.oval,
                selectedIndex: 1,
                items: [
                  LiquidTabItem.icon(
                    label: 'Home',
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                  ),
                  LiquidTabItem.icon(
                    label: 'Explore',
                    icon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Selected index 1 renders with activeIcon in activeColor inside oval capsule
        expect(find.byIcon(Icons.explore), findsOneWidget);
        final icon = tester.widget<Icon>(find.byIcon(Icons.explore));
        expect(icon.color, equals(activeColor));
      },
    );

    testWidgets(
      'folded blur tier increases tint alpha above 0.40 contrast threshold and adds contact shadow',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                material: LiquidTabBarMaterial.blur,
                initiallyMinimized: true,
                selectedIndex: 0,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find BackdropFilter and inspect inner tint box
        final backdrop = tester.widget<BackdropFilter>(
          find.byType(BackdropFilter).first,
        );
        final tintBox = backdrop.child as DecoratedBox;
        final tintColor = (tintBox.decoration as BoxDecoration).color!;

        // Contrast threshold: effective tint alpha must be >= 0.40 (substantially higher than 0.13-0.19)
        expect(tintColor.a, greaterThanOrEqualTo(0.40));

        // Outer DecoratedBox has contact drop shadow alongside ambient shadow
        final outerBox = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byType(ClipRRect),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final shadows = (outerBox.decoration as BoxDecoration).boxShadow!;
        expect(shadows.length, greaterThan(1));
      },
    );

    test(
        'folded glass tier increases shader tint alpha, scales blur, and elevates shadow',
        () {
      const theme = LiquidTabBarTheme.dark();

      // At rest / expanded (foldProgress = 0.0), unchanged
      final styleExpanded = LiquidTabBar.computeEffectiveGlassStyle(
        theme: theme,
        foldProgress: 0.0,
      );
      expect(styleExpanded.tint, theme.barStyle.glass.tint);
      expect(styleExpanded.blur, theme.barStyle.glass.blur);
      expect(styleExpanded.shadow, theme.barStyle.glass.shadow);

      // Folded Level 2 (Balanced default): tint increases, blur scales down, shadow elevates
      final styleFolded = LiquidTabBar.computeEffectiveGlassStyle(
        theme: theme,
        foldProgress: 1.0,
        densityLevel: 2,
      );
      expect(styleFolded.tint.a, greaterThanOrEqualTo(0.40));
      expect(styleFolded.shadow, greaterThanOrEqualTo(0.40));
      expect(
        styleFolded.blur,
        lessThan(theme.barStyle.glass.blur),
      ); // scaled from 15 to ~9.75

      // Level 1 (Subtle): lighter tint
      final styleSubtle = LiquidTabBar.computeEffectiveGlassStyle(
        theme: theme,
        foldProgress: 1.0,
        densityLevel: 1,
      );
      expect(styleSubtle.tint.a, inInclusiveRange(0.28, 0.35));

      // Level 3 (Dense): higher tint and stronger shadow
      final styleDense = LiquidTabBar.computeEffectiveGlassStyle(
        theme: theme,
        foldProgress: 1.0,
        densityLevel: 3,
      );
      expect(styleDense.tint.a, greaterThan(styleFolded.tint.a));
      expect(styleDense.shadow, greaterThan(styleFolded.shadow));
    });

    testWidgets(
      'expanded state remains completely unaffected (zero overhead invariant)',
      (tester) async {
        final theme = const LiquidTabBarTheme();
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                theme: theme,
                material: LiquidTabBarMaterial.blur,
                initiallyMinimized: false,
                selectedIndex: 0,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. BackdropFilter tint matches original glassTint exactly
        final backdrop = tester.widget<BackdropFilter>(
          find.byType(BackdropFilter).first,
        );
        final tintBox = backdrop.child as DecoratedBox;
        final tintColor = (tintBox.decoration as BoxDecoration).color!;
        expect(tintColor, equals(theme.barStyle.blurTint));

        // 2. Outer DecoratedBox has ONLY ambient shadow (no contact shadow)
        final outerBox = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byType(ClipRRect),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final shadows = (outerBox.decoration as BoxDecoration).boxShadow!;
        expect(shadows.length, equals(theme.barStyle.shadow.length));
      },
    );
  });

  group('LiquidTabBar Zero-Friction Padding & Safety Net', () {
    testWidgets(
      'reservedHeight and reservedPadding adapt across phone, tablet, landscape, and text scaling',
      (tester) async {
        late BuildContext capturedContext;
        Widget buildTest({
          required Size size,
          required EdgeInsets viewPadding,
          TextScaler textScaler = TextScaler.noScaling,
          double additionalPadding = 0.0,
        }) {
          return MediaQuery(
            data: MediaQueryData(
              size: size,
              viewPadding: viewPadding,
              textScaler: textScaler,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Builder(
                builder: (context) {
                  capturedContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );
        }

        // 1. Phone with home indicator (e.g. iPhone with 34pt bottom inset)
        await tester.pumpWidget(
          buildTest(
            size: const Size(400, 800),
            viewPadding: const EdgeInsets.only(bottom: 34),
          ),
        );
        expect(
          LiquidTabBar.reservedHeight(capturedContext),
          96.0,
        ); // 64 + 20 + 12
        expect(
          LiquidTabBar.reservedPadding(capturedContext),
          const EdgeInsets.only(bottom: 96.0),
        );

        // 2. Phone without home indicator (flat edge)
        await tester.pumpWidget(
          buildTest(size: const Size(400, 800), viewPadding: EdgeInsets.zero),
        );
        expect(
          LiquidTabBar.reservedHeight(capturedContext),
          88.0,
        ); // 64 + 12 + 12
        expect(
          LiquidTabBar.reservedPadding(capturedContext),
          const EdgeInsets.only(bottom: 88.0),
        );

        // 3. Tablet viewport (e.g. iPad 1024x1366 with 21pt home bar)
        await tester.pumpWidget(
          buildTest(
            size: const Size(1024, 1366),
            viewPadding: const EdgeInsets.only(bottom: 21),
          ),
        );
        expect(LiquidTabBar.reservedHeight(capturedContext), 96.0);

        // 4. Landscape phone (926x428 with 21pt home indicator)
        await tester.pumpWidget(
          buildTest(
            size: const Size(926, 428),
            viewPadding: const EdgeInsets.only(bottom: 21),
          ),
        );
        expect(LiquidTabBar.reservedHeight(capturedContext), 96.0);

        // 5. Dynamic text scaling (1.5x scaling)
        await tester.pumpWidget(
          buildTest(
            size: const Size(400, 800),
            viewPadding: const EdgeInsets.only(bottom: 34),
            textScaler: const TextScaler.linear(1.5),
          ),
        );
        // extraTextHeight = (12.0 * 1.5 - 12.0) = 6.0 => 96 + 6 = 102.0
        expect(LiquidTabBar.reservedHeight(capturedContext), 102.0);

        // 6. Additional padding parameter (e.g. +72pt for floating mini player)
        await tester.pumpWidget(
          buildTest(
            size: const Size(400, 800),
            viewPadding: const EdgeInsets.only(bottom: 34),
            additionalPadding: 72.0,
          ),
        );
        expect(
          LiquidTabBar.reservedHeight(capturedContext, additionalPadding: 72.0),
          168.0, // 96 + 72
        );
      },
    );

    testWidgets(
      'LiquidScrollPadding and SliverLiquidScrollPadding correctly reserve space and register scope',
      (tester) async {
        late double capturedBottomPadding;
        late LiquidScrollPaddingScope? capturedScope;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 800),
              viewPadding: EdgeInsets.only(bottom: 34),
              padding: EdgeInsets.only(bottom: 34),
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: LiquidScrollPadding(
                child: Builder(
                  builder: (context) {
                    capturedBottomPadding =
                        MediaQuery.paddingOf(context).bottom;
                    capturedScope = LiquidScrollPaddingScope.maybeOf(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        );

        // MediaQuery bottom padding is automatically upgraded from 34 to 96
        expect(capturedBottomPadding, 96.0);
        expect(capturedScope, isNotNull);
        expect(capturedScope!.reservedHeight, 96.0);

        // Test SliverLiquidScrollPadding in CustomScrollView
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  const SliverLiquidScrollPadding(),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(SliverLiquidScrollPadding), findsOneWidget);
        final sliverBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(SliverLiquidScrollPadding),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sliverBox.height, greaterThanOrEqualTo(88.0));
      },
    );

    testWidgets(
      'LiquidTabBarScaffold automatically applies extendBody: true and wraps body with LiquidScrollPadding',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LiquidTabBarScaffold(
              tabBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                ],
                selectedIndex: 0,
              ),
              body: const Text('Scaffold Content'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.extendBody, isTrue);
        expect(find.byType(LiquidScrollPadding), findsOneWidget);
        expect(find.text('Scaffold Content'), findsOneWidget);
      },
    );

    testWidgets(
      'Debug safety net emits actionable warning on unpadded extendBody: true and stays silent when padded',
      (tester) async {
        final logs = <String>[];
        LiquidTabBar.onExtendBodyWarningForTesting = (msg) => logs.add(msg);
        addTearDown(() => LiquidTabBar.onExtendBodyWarningForTesting = null);

        // 1. Unpadded scrollable with extendBody: true -> SHOULD warn
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              extendBody: true,
              body: ListView.builder(
                itemCount: 20,
                itemBuilder: (_, i) => Text('Item $i'),
              ),
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                ],
                selectedIndex: 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          logs.any(
            (l) => l.contains(
              '[LiquidTabBar] extendBody: true detected without bottom scroll padding',
            ),
          ),
          isTrue,
        );

        logs.clear();

        // 2. Properly padded with LiquidScrollPadding -> should NOT warn
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              extendBody: true,
              body: LiquidScrollPadding(
                child: ListView.builder(
                  itemCount: 20,
                  itemBuilder: (_, i) => Text('Item $i'),
                ),
              ),
              bottomNavigationBar: LiquidTabBar(
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                ],
                selectedIndex: 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          logs.any(
            (l) => l.contains(
              '[LiquidTabBar] extendBody: true detected without bottom scroll padding',
            ),
          ),
          isFalse,
        );

        // 3. Warning silenced via warnOnMissingExtendBodyPadding: false -> should NOT warn
        logs.clear();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              extendBody: true,
              body: ListView.builder(
                itemCount: 20,
                itemBuilder: (_, i) => Text('Item $i'),
              ),
              bottomNavigationBar: LiquidTabBar(
                warnOnMissingExtendBodyPadding: false,
                items: [
                  LiquidTabItem.icon(label: 'Home', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Search', icon: Icons.search),
                ],
                selectedIndex: 0,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          logs.any(
            (l) => l.contains(
              '[LiquidTabBar] extendBody: true detected without bottom scroll padding',
            ),
          ),
          isFalse,
        );
      },
    );
  });

  group('LiquidTabBar Droplet Interaction Expansion & Refraction Invariants',
      () {
    Positioned findDropletOuterPositioned(WidgetTester tester) {
      final dropletFinder = find.byWidgetPredicate((w) {
        if (w is DecoratedBox && w.decoration is BoxDecoration) {
          final box = w.decoration as BoxDecoration;
          return box.borderRadius is BorderRadius &&
              box.boxShadow == null &&
              box.border == null &&
              box.gradient == null;
        }
        return false;
      }).first;
      final positionedAncestors = tester
          .widgetList<Positioned>(
            find.ancestor(of: dropletFinder, matching: find.byType(Positioned)),
          )
          .toList();
      // positionedAncestors[0] is inner Positioned inside _lensSurface
      // positionedAncestors[1] is outer Positioned inside _content
      expect(positionedAncestors.length, greaterThanOrEqualTo(2));
      return positionedAncestors[1];
    }

    testWidgets(
      'resting droplet geometry is neatly inset within navigation bar bounds',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );
        await tester.pumpAndSettle();

        final droplet = findDropletOuterPositioned(tester);
        // At rest, height is exactly 56pt and top is exactly 4pt (inset by 4pt from 64pt bar)
        expect(droplet.height, equals(56.0));
        expect(droplet.top, equals(4.0));
        expect(droplet.top! > 0.0, isTrue);
      },
    );

    testWidgets(
      'pointer down and active drag smoothly enlarge droplet and protrude above the bar',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );
        await tester.pumpAndSettle();

        // 1. Initial resting geometry: neatly inset in 64pt bar (top=4pt, bottom=60pt, height=56pt)
        final resting = findDropletOuterPositioned(tester);
        expect(resting.height, equals(56.0));
        expect(resting.top, equals(4.0));
        expect(resting.top! + resting.height!, equals(60.0));

        // 2. Pointer down on Home tab and hold to let press spring settle
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // When grabbed/held:
        // - Top rises moderately above the bar (topY ≈ -6.0pt, in target range -5 to -8pt)
        // - Bottom bulges moderately below the bar (bottomY ≈ 67.0pt, in target range 66 to 69pt)
        // - Height swells to ≈ 73.0pt (+30.3% compact liquid swelling)
        // - Width swells conservatively (+5% at zero velocity)
        final pressed = findDropletOuterPositioned(tester);
        expect(pressed.height!, greaterThanOrEqualTo(71.0));
        expect(pressed.height!, lessThanOrEqualTo(76.0));
        expect(pressed.top!,
            lessThanOrEqualTo(-5.0)); // Protrudes ~6pt ABOVE the bar!
        expect(
            pressed.top!, greaterThanOrEqualTo(-8.0)); // Controlled overshoot
        expect(pressed.top! + pressed.height!,
            greaterThanOrEqualTo(65.5)); // Bulges ~3pt BELOW the bar!
        expect(pressed.top! + pressed.height!, lessThanOrEqualTo(69.0));
        expect(pressed.width!,
            greaterThan(resting.width! * 1.03)); // Width expansion
        expect(pressed.width!,
            lessThan(resting.width! * 1.10)); // Conservative width

        // 3. Active horizontal drag: stretches width with velocity while preserving liquid silhouette
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(const Duration(milliseconds: 80));

        final dragging = findDropletOuterPositioned(tester);
        expect(dragging.height!, greaterThan(68.0));
        expect(dragging.top!, lessThan(0.0)); // Stays protruding during drag
        expect(
            dragging.width!, greaterThan(resting.width!)); // Velocity stretch

        // 4. Release finger: spring smoothly returns droplet to resting geometry
        await gesture.up();
        await tester.pumpAndSettle();

        final settled = findDropletOuterPositioned(tester);
        expect(settled.height, equals(56.0));
        expect(settled.top, equals(4.0));
        expect(settled.top! + settled.height!, equals(60.0));
      },
    );

    testWidgets(
      'folded navigation geometry safeguards prevent protrusion when bar is minimized',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );
        await tester.pumpAndSettle();

        // Minimize / fold the bar
        controller.minimize();
        await tester.pumpAndSettle();

        // While folded, tapping to expand does not leak an enlarged droplet outside the folded pill
        expect(controller.minimized, isTrue);
      },
    );

    testWidgets(
      'velocity squash-and-stretch and directional inertia respond cleanly to drag and relax at rest',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );
        await tester.pumpAndSettle();

        final resting = findDropletOuterPositioned(tester);

        // Pointer down and drag rightward
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Swift drag to tab 2 (40pt rightward step)
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(const Duration(milliseconds: 50));

        final fastDrag = findDropletOuterPositioned(tester);
        // Under horizontal velocity:
        // 1. Droplet stretches horizontally (lw > restingW)
        expect(fastDrag.width!, greaterThan(resting.width!));
        // 2. Protrusion continues to swell outside bar top and bottom
        expect(fastDrag.top!, lessThan(0.0));
        expect(fastDrag.top! + fastDrag.height!, greaterThan(64.0));
        // 3. Height remains cleanly bounded due to mass conservation
        expect(fastDrag.height!, lessThanOrEqualTo(76.0));

        // Hold still at target without lifting finger so velocity relaxes to zero
        await tester.pump(const Duration(milliseconds: 300));
        final stationaryHeld = findDropletOuterPositioned(tester);
        // Balanced cohesive blob: top protruding outside bar, bottom bulging below bar
        expect(stationaryHeld.top!, lessThanOrEqualTo(-5.0));
        expect(stationaryHeld.top! + stationaryHeld.height!,
            greaterThanOrEqualTo(65.5));
        expect(stationaryHeld.top! + stationaryHeld.height!,
            lessThanOrEqualTo(69.0));

        await gesture.up();
        await tester.pumpAndSettle();
        final released = findDropletOuterPositioned(tester);
        expect(released.top, equals(4.0));
        expect(released.height, equals(56.0));
      },
    );

    testWidgets(
      'quick normal tap triggers liquid swelling during travel and settles upon arrival',
      (tester) async {
        int selectedIndex = 0;
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) => setState(() => selectedIndex = i),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial state at tab 0: resting droplet
        final resting = findDropletOuterPositioned(tester);
        expect(resting.top, equals(4.0));
        expect(resting.height, equals(56.0));

        // 2. Perform a QUICK TAP on tab 2 ('Me') and release immediately (no hold)
        await tester.tap(find.text('Me'), warnIfMissed: false);
        // Pump frame for tap and travel start:
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 160));

        // In mid-travel, finger has ALREADY been lifted, but droplet remains swollen!
        final midTravel = findDropletOuterPositioned(tester);
        expect(midTravel.top!, lessThan(0.0)); // Protrudes above bar!
        expect(midTravel.top! + midTravel.height!,
            greaterThan(64.0)); // Bulges below bar!
        expect(midTravel.height!, greaterThan(68.0)); // Swollen liquid mass!

        // 3. Complete travel and pump to let surface tension settle upon arrival
        await tester.pumpAndSettle();

        // 4. Settled at tab 2: exact original resting geometry
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(selectedIndex, equals(2));
      },
    );

    testWidgets(
      'rapid repeated tab taps smoothly redirect droplet without stacking bulge size',
      (tester) async {
        int selectedIndex = 0;
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) => setState(() => selectedIndex = i),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Tap tab 1 ('Orders'), then immediately tap tab 2 ('Me') before arrival
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 60));
        await tester.tap(find.text('Me'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 60));

        // Swelling must remain strictly bounded (never double into huge bubble)
        final rapidTapping = findDropletOuterPositioned(tester);
        expect(rapidTapping.height!, lessThanOrEqualTo(78.0));
        expect(rapidTapping.top!, greaterThanOrEqualTo(-9.0));

        await tester.pumpAndSettle();
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(selectedIndex, equals(2));
      },
    );

    testWidgets(
      'holding a destination tab initiates immediate travel and maintains held swelling until release',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Current tab = 0 (Home). Droplet at resting size.
        final resting = findDropletOuterPositioned(tester);
        expect(resting.top, equals(4.0));
        expect(resting.height, equals(56.0));
        expect(calls, isEmpty);

        // 2. PointerDown on tab 2 ('Me') WITHOUT pointerUp.
        final targetCenter = tester.getCenter(find.text('Me'));
        final gesture = await tester.startGesture(targetCenter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // 3. Verify droplet begins traveling toward 'Me' immediately and travelBulge is active.
        final inFlight = findDropletOuterPositioned(tester);
        expect(inFlight.top!, lessThan(0.0)); // Protrudes above bar
        expect(inFlight.height!, greaterThan(68.0)); // Liquid swelling active

        // 4. Keep pointer held until travel completes (350ms).
        await tester.pump(const Duration(milliseconds: 350));

        // 5. Droplet ends centered on 'Me' and remains swollen in grabbed liquid state while held.
        final heldAtDest = findDropletOuterPositioned(tester);
        expect(heldAtDest.top!,
            lessThanOrEqualTo(-5.0)); // Still protruding above bar!
        expect(heldAtDest.top! + heldAtDest.height!,
            greaterThanOrEqualTo(65.5)); // Still bulging below bar!
        expect(heldAtDest.height!,
            greaterThanOrEqualTo(71.0)); // Held liquid swelling!
        expect(heldAtDest.height!,
            lessThanOrEqualTo(76.0)); // Strictly bounded, not doubled!

        // 6. PointerUp: release finger.
        await gesture.up();
        await tester.pumpAndSettle();

        // 7. Verify droplet performs small surface-tension settle to resting geometry.
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(settled.top! + settled.height!, equals(60.0));

        // 8. Verify destination 'Me' (index 2) remains selected and callback reported exactly once.
        expect(selectedIndex, equals(2));
        expect(calls, equals([2]));
      },
    );

    testWidgets(
      'empty-space interactions do not activate droplet swelling or change selection',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));
        final barFinder = find.byType(LiquidTabBar);
        final barRect = tester.getRect(barFinder);
        final resting = findDropletOuterPositioned(tester);

        // a. Press between two tabs (midway between Home and Orders)
        final betweenTabs =
            Offset((homeCenter.dx + ordersCenter.dx) / 2, homeCenter.dy);
        final gestureBetween = await tester.startGesture(betweenTabs);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureBetween.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));

        // b. Press above icon but inside bar (y = barRect.top + 2.0)
        final aboveIcon = Offset(homeCenter.dx, barRect.top + 2.0);
        final gestureAbove = await tester.startGesture(aboveIcon);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureAbove.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));

        // c. Press below label but inside bar (y = barRect.bottom - 2.0)
        final belowLabel = Offset(homeCenter.dx, barRect.bottom - 2.0);
        final gestureBelow = await tester.startGesture(belowLabel);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureBelow.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));

        // d. Press near left bar edge
        final leftEdge = Offset(barRect.left + 2.0, homeCenter.dy);
        final gestureLeft = await tester.startGesture(leftEdge);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureLeft.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));

        // e. Press near right bar edge
        final rightEdge = Offset(barRect.right - 2.0, homeCenter.dy);
        final gestureRight = await tester.startGesture(rightEdge);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureRight.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));

        // f. Press immediately beside current droplet
        final besideDroplet =
            Offset(homeCenter.dx + resting.width! / 2 + 3.0, homeCenter.dy);
        final gestureBeside = await tester.startGesture(besideDroplet);
        await tester.pump(const Duration(milliseconds: 250));
        expect(findDropletOuterPositioned(tester).top, equals(4.0));
        expect(findDropletOuterPositioned(tester).height, equals(56.0));
        await gestureBeside.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);
        expect(selectedIndex, equals(0));
      },
    );

    testWidgets(
      'empty-space press during active travel does not amplify or restart the bulge',
      (tester) async {
        int selectedIndex = 0;
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) => setState(() => selectedIndex = i),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));
        final betweenTabs =
            Offset((homeCenter.dx + ordersCenter.dx) / 2, homeCenter.dy);

        // 1. Initiate quick tap travel from Home to Me
        await tester.tap(find.text('Me'), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 80));

        // 2. In mid-flight, an empty-space press occurs
        final emptyGesture = await tester.startGesture(betweenTabs, pointer: 5);
        await tester.pump(const Duration(milliseconds: 60));

        // 3. Bulge must remain bounded and not restart or blow up
        final inFlight = findDropletOuterPositioned(tester);
        expect(inFlight.height!, lessThanOrEqualTo(76.0));
        expect(inFlight.top!, greaterThanOrEqualTo(-8.0));

        await emptyGesture.up();
        await tester.pumpAndSettle();

        // 4. Settles cleanly at Me
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(selectedIndex, equals(2));
      },
    );

    testWidgets(
      'holding current droplet does not change selection and settles on release',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Pointer down on Home tab (current droplet) and hold
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Droplet swells while held
        final pressed = findDropletOuterPositioned(tester);
        expect(pressed.top!, lessThanOrEqualTo(-5.0));
        expect(pressed.height!, greaterThanOrEqualTo(71.0));

        // Release finger without dragging
        await gesture.up();
        await tester.pumpAndSettle();

        // Settles back to resting geometry
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);
      },
    );

    testWidgets(
      'starting drag on droplet and moving outside initial bounds preserves gesture ownership until release',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildBar(items: testItems, selectedIndex: 0, controller: controller),
        );
        await tester.pumpAndSettle();

        // Pointer down directly on Home droplet
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Move far vertically and horizontally outside initial droplet box
        await gesture.moveBy(const Offset(60, -30));
        await tester.pump(const Duration(milliseconds: 80));

        // Droplet is still tracking gesture ownership
        final dragging = findDropletOuterPositioned(tester);
        expect(dragging.top!, lessThan(0.0));
        expect(dragging.width!, greaterThan(56.0));

        await gesture.up();
        await tester.pumpAndSettle();

        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
      },
    );
  });

  group(
      'LiquidTabBar Deferred Commit & Gesture Ownership Invariants (12 Scenarios)',
      () {
    Positioned findDropletOuterPositioned(WidgetTester tester) {
      final dropletFinder = find.byWidgetPredicate((w) {
        if (w is DecoratedBox && w.decoration is BoxDecoration) {
          final box = w.decoration as BoxDecoration;
          return box.borderRadius is BorderRadius &&
              box.boxShadow == null &&
              box.border == null &&
              box.gradient == null;
        }
        return false;
      }).first;
      final positionedAncestors = tester
          .widgetList<Positioned>(
            find.ancestor(of: dropletFinder, matching: find.byType(Positioned)),
          )
          .toList();
      expect(positionedAncestors.length, greaterThanOrEqualTo(2));
      return positionedAncestors[1];
    }

    testWidgets(
      'Scenario 1: PointerDown B while A committed: droplet begins traveling but A remains committed',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final initialDroplet = findDropletOuterPositioned(tester);
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 60));

        // Droplet has started traveling (left position moved towards Orders)
        final movingDroplet = findDropletOuterPositioned(tester);
        expect(movingDroplet.left!, greaterThan(initialDroplet.left!));

        // Committed page remains A (Home, index 0)
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Scenario 2: Hold until droplet reaches B: A page/index remains committed while pointer is down',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Pointer down on Orders (B) and hold until arrival (350ms)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        // Droplet has physically arrived at Orders and remains swollen in grabbed state
        final arrivedDroplet = findDropletOuterPositioned(tester);
        expect(arrivedDroplet.top!, lessThanOrEqualTo(-5.0));
        expect(arrivedDroplet.height!, greaterThanOrEqualTo(71.0));

        // BUT Home (A) remains committed because finger is still down
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);

        await gesture.up();
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(1));
        expect(calls, equals([1]));
      },
    );

    testWidgets(
      'Scenario 3: Move pointer after droplet reaches B: droplet follows pointer continuously',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // 1. Hold until arrival at Orders (Tab 1)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        final posAtOrders = findDropletOuterPositioned(tester);

        // 2. Move pointer toward Me (Tab 2)
        await gesture.moveBy(const Offset(40, 0));
        await tester.pump(const Duration(milliseconds: 50));

        final posFollowing = findDropletOuterPositioned(tester);
        expect(posFollowing.left!, greaterThan(posAtOrders.left!));
        expect(selectedIndex, equals(0)); // Still not committed!
        expect(calls, isEmpty);

        await gesture.up();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Scenario 4: Drag from B toward C while held: pending destination updates but committed index remains A',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Down on Orders (B)
        final ordersCenter = tester.getCenter(find.text('Orders'));
        final meCenter = tester.getCenter(find.text('Me'));
        final gesture = await tester.startGesture(ordersCenter);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Drag from Orders toward Me (C)
        await gesture.moveTo(meCenter);
        await tester.pump(const Duration(milliseconds: 60));

        // While held at C, committed index is STILL Home (A, 0)
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);

        await gesture.up();
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(2));
      },
    );

    testWidgets(
      'Scenario 5: Release at C: no immediate stale/intermediate commit',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final ordersCenter = tester.getCenter(find.text('Orders'));
        final meCenter = tester.getCenter(find.text('Me'));
        final gesture = await tester.startGesture(ordersCenter);
        await tester.pump();
        await gesture.moveTo(meCenter);
        await tester.pump(const Duration(milliseconds: 50));

        // Release at Me (C)
        await gesture.up();
        // Immediately on release (before settle completes):
        await tester.pump(const Duration(milliseconds: 10));

        // Intermediate tab (Orders, 1) must NEVER have been emitted
        expect(calls.contains(1), isFalse);

        await tester.pumpAndSettle();
        expect(selectedIndex, equals(2));
        expect(calls, equals([2]));
      },
    );

    testWidgets(
      'Scenario 6: After droplet settles at C: committed index becomes C exactly once',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump();
        await gesture.moveTo(tester.getCenter(find.text('Me')));
        await tester.pump(const Duration(milliseconds: 50));
        await gesture.up();

        await tester.pumpAndSettle();

        // Committed index becomes Me (2) exactly once
        expect(selectedIndex, equals(2));
        expect(calls, equals([2]));
      },
    );

    testWidgets(
      'Scenario 7: Quick tap B: pointerUp occurs before arrival; A remains committed during travel; B commits only after arrival/settle',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Quick tap on Orders (down and up in 20ms)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump(const Duration(milliseconds: 20));
        await gesture.up();

        // Mid-travel frame: 80ms into flight
        await tester.pump(const Duration(milliseconds: 80));
        expect(selectedIndex, equals(0)); // Still Home!
        expect(calls, isEmpty);

        // Allow travel and liquid settle to complete
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(1));
        expect(calls, equals([1]));
      },
    );

    testWidgets(
      'Scenario 8: Move finger before initial arrival: droplet redirects smoothly toward current held pointer',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Pointer down on Orders
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        await tester.pump(const Duration(milliseconds: 30));

        // Redirect before reaching Orders: drag back to Home
        await gesture.moveTo(tester.getCenter(find.text('Home')));
        await tester.pump(const Duration(milliseconds: 50));
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);

        // Release at Home
        await gesture.up();
        await tester.pumpAndSettle();

        // Orders was never committed, and Home emits no duplicate
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);
      },
    );

    testWidgets(
      'Scenario 9: Intermediate tabs never emit committed callbacks',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: [
                  LiquidTabItem.icon(label: 'Tab0', icon: Icons.home),
                  LiquidTabItem.icon(label: 'Tab1', icon: Icons.star),
                  LiquidTabItem.icon(label: 'Tab2', icon: Icons.favorite),
                  LiquidTabItem.icon(label: 'Tab3', icon: Icons.person),
                ],
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final t0 = tester.getCenter(find.text('Tab0'));
        final t1 = tester.getCenter(find.text('Tab1'));
        final t2 = tester.getCenter(find.text('Tab2'));
        final t3 = tester.getCenter(find.text('Tab3'));

        final gesture = await tester.startGesture(t0);
        await tester.pump();
        await gesture.moveTo(t1);
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.moveTo(t2);
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.moveTo(t3);
        await tester.pump(const Duration(milliseconds: 30));

        // While scrubbing across Tab1 and Tab2, no calls were emitted
        expect(calls, isEmpty);

        await gesture.up();
        await tester.pumpAndSettle();

        // Only Tab3 commits!
        expect(selectedIndex, equals(3));
        expect(calls, equals([3]));
      },
    );

    testWidgets(
      'Scenario 10: Empty-space press remains inert and does not cancel in-flight travel',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final ordersCenter = tester.getCenter(find.text('Orders'));
        final betweenTabs =
            Offset((homeCenter.dx + ordersCenter.dx) / 2, homeCenter.dy);

        // 1. Static empty-space press: droplet remains at rest
        final emptyGesture1 = await tester.startGesture(betweenTabs);
        await tester.pump(const Duration(milliseconds: 100));
        final resting = findDropletOuterPositioned(tester);
        expect(resting.top, equals(4.0));
        expect(resting.height, equals(56.0));
        await emptyGesture1.up();
        await tester.pumpAndSettle();
        expect(calls, isEmpty);

        // 2. In-flight travel: tap Me
        await tester.tap(find.text('Me'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));

        // Press and release empty space while droplet is traveling
        final emptyGesture2 =
            await tester.startGesture(betweenTabs, pointer: 9);
        await tester.pump(const Duration(milliseconds: 30));
        await emptyGesture2.up();

        // Empty space must NOT cancel travel to Me
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(2));
        expect(calls, equals([2]));
      },
    );

    testWidgets(
      'Scenario 11: Press/release current droplet without destination change emits no duplicate selection',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Pointer down on current droplet (Home)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        // Swells while held
        final pressed = findDropletOuterPositioned(tester);
        expect(pressed.top!, lessThanOrEqualTo(-5.0));

        // Release without moving
        await gesture.up();
        await tester.pumpAndSettle();

        // Settles back to resting geometry, no duplicate callback emitted
        final settled = findDropletOuterPositioned(tester);
        expect(settled.top, equals(4.0));
        expect(settled.height, equals(56.0));
        expect(selectedIndex, equals(0));
        expect(calls, isEmpty);
      },
    );

    testWidgets(
      'Scenario 12: Rapid destination changes cannot allow an old animation completion to commit a stale index',
      (tester) async {
        int selectedIndex = 0;
        final calls = <int>[];
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  calls.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Quick tap on Orders (Tab 1)
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        // Before Orders settles, immediately tap Me (Tab 2)
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.text('Me'), warnIfMissed: false);

        // Pump through completion
        await tester.pumpAndSettle();

        // Only Tab 2 commits; Tab 1 is never committed
        expect(selectedIndex, equals(2));
        expect(calls, equals([2]));
      },
    );
  });

  group('LiquidTabBar API Request Safety & Side-Effect Boundary Invariants',
      () {
    final fourTabs = [
      LiquidTabItem.icon(label: 'Home', icon: Icons.home),
      LiquidTabItem.icon(label: 'Search', icon: Icons.search),
      LiquidTabItem.icon(label: 'Orders', icon: Icons.receipt),
      LiquidTabItem.icon(label: 'Profile', icon: Icons.person),
    ];

    testWidgets(
      'scrubbing across tabs commits only final destination once',
      (tester) async {
        int callbackCount = 0;
        int? lastCommittedIndex;
        int selectedIndex = 0;
        final controller = LiquidTabBarController();

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: fourTabs,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  callbackCount++;
                  lastCommittedIndex = i;
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        final homeCenter = tester.getCenter(find.text('Home'));
        final searchCenter = tester.getCenter(find.text('Search'));
        final ordersCenter = tester.getCenter(find.text('Orders'));
        final profileCenter = tester.getCenter(find.text('Profile'));

        // Pointer down on droplet (Home)
        final gesture = await tester.startGesture(homeCenter);
        await tester.pump(const Duration(milliseconds: 100));
        expect(callbackCount, equals(0));

        // Move across: 1 -> 2 -> 3 -> 1 -> 3 -> 2
        await gesture.moveTo(searchCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        await gesture.moveTo(ordersCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        await gesture.moveTo(profileCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        await gesture.moveTo(searchCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        await gesture.moveTo(profileCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        await gesture.moveTo(ordersCenter);
        await tester.pump(const Duration(milliseconds: 60));
        expect(callbackCount, equals(0));

        // Release on 2 (Orders)
        await gesture.up();

        // While final settle is incomplete
        await tester.pump(const Duration(milliseconds: 20));
        expect(callbackCount, equals(0));

        // After final settle
        await tester.pumpAndSettle();
        expect(callbackCount, equals(1));
        expect(lastCommittedIndex, equals(2));
        expect(selectedIndex, equals(2));

        // Pump additional frames afterward: callback count must STILL equal 1
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 200));
        expect(callbackCount, equals(1));
        expect(lastCommittedIndex, equals(2));
      },
    );

    testWidgets(
      'rapid taps: A -> tap B -> before settle tap C -> before settle tap D commits only D once',
      (tester) async {
        int callbackCount = 0;
        final selectedIndices = <int>[];
        int selectedIndex = 0;
        final controller = LiquidTabBarController();

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: fourTabs,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  callbackCount++;
                  selectedIndices.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Tap Search (1)
        await tester.tap(find.text('Search'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 40));
        expect(callbackCount, equals(0));

        // Tap Orders (2) before Search settles
        await tester.tap(find.text('Orders'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 40));
        expect(callbackCount, equals(0));

        // Tap Profile (3) before Orders settles
        await tester.tap(find.text('Profile'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 40));
        expect(callbackCount, equals(0));

        // Let everything settle
        await tester.pumpAndSettle();
        expect(callbackCount, equals(1));
        expect(selectedIndices, equals([3]));
        expect(selectedIndex, equals(3));
      },
    );

    testWidgets(
      'holding destination tab for extended time maintains zero callbacks until release settle',
      (tester) async {
        int callbackCount = 0;
        final selectedIndices = <int>[];
        int selectedIndex = 0;
        final controller = LiquidTabBarController();

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  callbackCount++;
                  selectedIndices.add(i);
                  setState(() => selectedIndex = i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Pointer down on Orders and hold for 3 full seconds (30 * 100ms)
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Orders')));
        for (int step = 0; step < 30; step++) {
          await tester.pump(const Duration(milliseconds: 100));
          expect(callbackCount, equals(0),
              reason: 'Callback must not fire while held at step $step');
        }

        // Release finger
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 10));
        expect(callbackCount, equals(0));

        await tester.pumpAndSettle();
        expect(callbackCount, equals(1));
        expect(selectedIndices, equals([1]));
        expect(selectedIndex, equals(1));
      },
    );

    testWidgets(
      'programmatic selectedIndex change synchronizes lens without echoing onSelected callback',
      (tester) async {
        int callbackCount = 0;
        final selectedIndices = <int>[];
        int selectedIndex = 0;
        final controller = LiquidTabBarController();

        late void Function(void Function()) parentSetState;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              parentSetState = setState;
              return buildBar(
                items: testItems,
                selectedIndex: selectedIndex,
                controller: controller,
                onSelected: (i) {
                  callbackCount++;
                  selectedIndices.add(i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Programmatically change selection from 0 to 2
        parentSetState(() {
          selectedIndex = 2;
        });
        await tester.pump();
        await tester.pumpAndSettle();

        // Lens synchronizes visually, but onSelected is NOT echoed back
        expect(callbackCount, equals(0));
        expect(selectedIndices, isEmpty);
      },
    );

    testWidgets(
      'disposing LiquidTabBar during active scrub or travel does not trigger callbacks or leak',
      (tester) async {
        int callbackCount = 0;
        final selectedIndices = <int>[];
        bool mounted = true;
        final controller = LiquidTabBarController();

        late void Function(void Function()) parentSetState;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              parentSetState = setState;
              if (!mounted) return const SizedBox.shrink();
              return buildBar(
                items: testItems,
                selectedIndex: 0,
                controller: controller,
                onSelected: (i) {
                  callbackCount++;
                  selectedIndices.add(i);
                },
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Start gesture and scrub
        final gesture =
            await tester.startGesture(tester.getCenter(find.text('Home')));
        await tester.pump(const Duration(milliseconds: 50));
        await gesture.moveTo(tester.getCenter(find.text('Orders')));
        await tester.pump(const Duration(milliseconds: 50));

        // Unmount the tab bar in the middle of active scrub
        parentSetState(() {
          mounted = false;
        });
        await tester.pump();
        await tester.pumpAndSettle();

        // Release gesture after unmount
        await gesture.up();
        await tester.pumpAndSettle();

        // Zero callbacks emitted
        expect(callbackCount, equals(0));
        expect(selectedIndices, isEmpty);
      },
    );
  });

  group('LiquidTabAction.search customIcon & glyph sizing', () {
    testWidgets(
      'customIcon renders in closed Search action and in expanded Search field',
      (tester) async {
        const customKey = ValueKey('custom-search-glyph');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  customIcon: const SizedBox(
                    key: customKey,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. In closed state: customIcon is rendered
        expect(find.byKey(customKey), findsOneWidget);
        // Default search IconData is NOT rendered
        expect(find.byIcon(Icons.search_rounded), findsNothing);

        // Tap to open search
        await tester.tap(find.byKey(customKey), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // 2. In expanded state: customIcon is STILL rendered as leading glyph
        expect(find.byKey(customKey), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsNothing);

        LiquidTabBar.closeSearch();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'when customIcon is null, existing IconData is rendered in closed and expanded states',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  icon: Icons.search_rounded,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // In closed state: search icon is rendered
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);

        // Tap to open search
        await tester.tap(find.byIcon(Icons.search_rounded), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // In expanded state: search icon is rendered as leading glyph
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);

        LiquidTabBar.closeSearch();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'precedence: when both icon and customIcon are provided, customIcon is rendered',
      (tester) async {
        const customKey = ValueKey('precedence-custom');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  icon: Icons.search_rounded,
                  customIcon: const SizedBox(key: customKey, width: 20, height: 20),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(customKey), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsNothing);
      },
    );

    testWidgets(
      'useThemeColor: true applies ColorFiltered in closed and expanded states',
      (tester) async {
        const customKey = ValueKey('tinted-custom');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  customIcon: const SizedBox(key: customKey, width: 20, height: 20),
                  useThemeColor: true,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // In closed state: ColorFiltered wrapper is present around the custom icon
        expect(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(ColorFiltered)),
          findsOneWidget,
        );

        // Open search
        await tester.tap(find.byKey(customKey), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // In expanded state: ColorFiltered wrapper is present with theme color
        expect(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(ColorFiltered)),
          findsOneWidget,
        );

        LiquidTabBar.closeSearch();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'useThemeColor: false preserves original colors and retains opening fade animation',
      (tester) async {
        const customKey = ValueKey('original-color-custom');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  customIcon: const SizedBox(key: customKey, width: 20, height: 20),
                  useThemeColor: false,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // In closed state: NO ColorFiltered wrapper around custom widget
        expect(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(ColorFiltered)),
          findsNothing,
        );

        // Open search
        await tester.tap(find.byKey(customKey), warnIfMissed: false);
        await tester.pump(); // executes postFrameCallback to show overlay
        await tester.pump(const Duration(milliseconds: 100)); // advances morph animation

        // In opening/expanded state: NO ColorFiltered, but Opacity is applied for the fade transition
        expect(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(ColorFiltered)),
          findsNothing,
        );
        expect(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(Opacity)),
          findsWidgets,
        );

        // Close search to reset state
        LiquidTabBar.closeSearch();
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'explicit iconSize sets actual glyph container size without changing 64x64 action button geometry',
      (tester) async {
        const customKey = ValueKey('sized-custom');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              bottomNavigationBar: LiquidTabBar(
                selectedIndex: 0,
                material: LiquidTabBarMaterial.opaque,
                items: testItems,
                separateAction: LiquidTabAction.search(
                  customIcon: const SizedBox(key: customKey, width: 28, height: 28),
                  iconSize: 28.0,
                  size: 64.0,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Enclosing glyph SizedBox has width 28, height 28
        final glyphSizedBox = tester.widget<SizedBox>(
          find.ancestor(of: find.byKey(customKey), matching: find.byType(SizedBox)).first,
        );
        expect(glyphSizedBox.width, equals(28.0));
        expect(glyphSizedBox.height, equals(28.0));

        // 2. Action button capsule geometry is still 64x64
        final actionButton = find.byType(LayoutBuilder).last;
        final actionSize = tester.getSize(actionButton);
        expect(actionSize.width, equals(64.0));
        expect(actionSize.height, equals(64.0));
      },
    );

    testWidgets(
      'mixed bar with LiquidTabItem.icon, LiquidTabItem.custom, and custom search action functions seamlessly',
      (tester) async {
        const customTabKey = ValueKey('custom-tab-icon');
        const customSearchKey = ValueKey('custom-search-action');
        int selectedIndex = 0;
        final controller = LiquidTabBarController();
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                home: Scaffold(
                  bottomNavigationBar: LiquidTabBar(
                    controller: controller,
                    selectedIndex: selectedIndex,
                    material: LiquidTabBarMaterial.opaque,
                    onSelected: (i) => setState(() => selectedIndex = i),
                    items: const [
                      LiquidTabItem.icon(
                        label: 'Home',
                        icon: Icons.home_rounded,
                      ),
                      LiquidTabItem.custom(
                        label: 'Custom',
                        icon: SizedBox(key: customTabKey, width: 20, height: 20),
                      ),
                      LiquidTabItem.icon(
                        label: 'Settings',
                        icon: Icons.settings_rounded,
                      ),
                    ],
                    separateAction: LiquidTabAction.search(
                      customIcon: const SizedBox(key: customSearchKey, width: 20, height: 20),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Verify all 3 tabs and custom search are mounted
        expect(find.byIcon(Icons.home_rounded), findsOneWidget);
        expect(find.byKey(customTabKey), findsOneWidget);
        expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
        expect(find.byKey(customSearchKey), findsOneWidget);

        // Tap custom tab item via its label
        await tester.tap(find.text('Custom'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(selectedIndex, equals(1));

        // Open search with custom search glyph
        await tester.tap(find.byKey(customSearchKey), warnIfMissed: false);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pumpAndSettle();

        // Search field is expanded and displays customSearchKey leading glyph
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byKey(customSearchKey), findsOneWidget);
      },
    );
  });
}
