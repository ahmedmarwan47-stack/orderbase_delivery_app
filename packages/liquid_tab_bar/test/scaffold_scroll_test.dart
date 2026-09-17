import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:liquid_tab_bar/src/test_overrides.dart';

void main() {
  List<LiquidTabItem> sampleItems() => [
        LiquidTabItem.icon(icon: Icons.home_rounded, label: 'Home'),
        LiquidTabItem.icon(icon: Icons.search_rounded, label: 'Search'),
        LiquidTabItem.icon(icon: Icons.person_rounded, label: 'Profile'),
      ];

  Widget buildApp({
    required Widget body,
    LiquidTabBarController? controller,
    bool shrinkOnScroll = true,
  }) {
    return MaterialApp(
      home: LiquidTabBarScaffold(
        tabBar: LiquidTabBar(
          controller: controller,
          shrinkOnScroll: shrinkOnScroll,
          selectedIndex: 0,
          items: sampleItems(),
        ),
        body: body,
      ),
    );
  }

  group('LiquidTabBarScaffold Zero-Config Auto Folding', () {
    // 1. ListView: scroll down folds, scroll up expands
    testWidgets(
      'ListView automatically folds on scroll down and expands on scroll up',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildApp(
            controller: controller,
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (_, i) =>
                  SizedBox(height: 60, child: Text('Item $i')),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.minimized, isFalse);

        // Scroll down (drag upwards by -200)
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);

        // Scroll up (drag downwards by +200)
        await tester.drag(find.byType(ListView), const Offset(0, 200));
        await tester.pumpAndSettle();
        expect(controller.minimized, isFalse);
      },
    );

    // 2. shrinkOnScroll false does nothing
    testWidgets('shrinkOnScroll: false disables automatic folding', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: controller,
          shrinkOnScroll: false,
          body: ListView.builder(
            itemCount: 100,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('Item $i')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.minimized, isFalse);
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(controller.minimized, isFalse);
    });

    // 3. GridView automatic folding
    testWidgets('GridView automatically folds on vertical scroll', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: controller,
          body: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: 80,
            itemBuilder: (_, i) => GridTile(child: Text('Tile $i')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.minimized, isFalse);
      await tester.drag(find.byType(GridView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);
    });

    // 4. SingleChildScrollView automatic folding
    testWidgets(
      'SingleChildScrollView automatically folds on vertical scroll',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          buildApp(
            controller: controller,
            body: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  60,
                  (i) => SizedBox(height: 50, child: Text('Row $i')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.minimized, isFalse);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -250),
        );
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);
      },
    );

    // 5. CustomScrollView + SliverList automatic folding
    testWidgets('CustomScrollView with Slivers automatically folds', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: controller,
          body: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => SizedBox(height: 60, child: Text('Sliver $i')),
                  childCount: 80,
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.minimized, isFalse);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -250));
      await tester.pumpAndSettle();
      expect(controller.minimized, isTrue);
    });

    // 6. Nested horizontal ListView does not affect folding
    testWidgets('Horizontal nested scroll does not trigger folding', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: controller,
          body: ListView(
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 40,
                  itemBuilder: (_, i) => Container(
                    width: 100,
                    color: Colors.blue[(i % 9 + 1) * 100],
                    child: Center(child: Text('Card $i')),
                  ),
                ),
              ),
              ...List.generate(
                50,
                (i) => SizedBox(height: 60, child: Text('Vertical $i')),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.minimized, isFalse);

      // Drag horizontally on the inner horizontal list
      final horizontalFinder = find.byType(ListView).first;
      await tester.drag(horizontalFinder, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Should remain expanded
      expect(controller.minimized, isFalse);
    });

    // 7. Static/non-scrollable body does not crash and remains expanded
    testWidgets('Non-scrollable body remains expanded without exceptions', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: controller,
          body: const Center(child: Text('Static Settings Screen')),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.minimized, isFalse);
      expect(find.text('Static Settings Screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // 8. User-provided controller is updated and not replaced
    testWidgets('User-provided controller is updated by automatic scrolling', (
      tester,
    ) async {
      final userController = LiquidTabBarController();
      await tester.pumpWidget(
        buildApp(
          controller: userController,
          body: ListView.builder(
            itemCount: 80,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('Item $i')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(userController.minimized, isFalse);
      await tester.drag(find.byType(ListView), const Offset(0, -250));
      await tester.pumpAndSettle();

      expect(userController.minimized, isTrue);
    });

    // 9. Existing manual NotificationListener inside LiquidTabBarScaffold
    // proves identical ScrollNotification deduplication
    testWidgets(
      'NotificationListener inside LiquidTabBarScaffold deduplicates identically',
      (tester) async {
        final controller = LiquidTabBarController();
        int manualCallCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: LiquidTabBarScaffold(
              tabBar: LiquidTabBar(
                controller: controller,
                shrinkOnScroll: true,
                selectedIndex: 0,
                items: sampleItems(),
              ),
              body: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  manualCallCount++;
                  // Call handleScroll manually as an existing app would do
                  controller.handleScroll(notification);
                  return false; // Bubble to scaffold
                },
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (_, i) =>
                      SizedBox(height: 60, child: Text('Item $i')),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(ListView), const Offset(0, -250));
        await tester.pumpAndSettle();

        expect(manualCallCount, greaterThan(0));
        expect(controller.minimized, isTrue);

        // Expand back up
        await tester.drag(find.byType(ListView), const Offset(0, 250));
        await tester.pumpAndSettle();
        expect(controller.minimized, isFalse);
      },
    );

    // 10. Normal Scaffold + manual controller.handleScroll still works
    testWidgets(
      'Normal Scaffold with manual controller.handleScroll still works',
      (tester) async {
        final controller = LiquidTabBarController();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              extendBody: true,
              body: NotificationListener<ScrollNotification>(
                onNotification: controller.handleScroll,
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (_, i) =>
                      SizedBox(height: 60, child: Text('Item $i')),
                ),
              ),
              bottomNavigationBar: LiquidTabBar(
                controller: controller,
                shrinkOnScroll: true,
                selectedIndex: 0,
                items: sampleItems(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(controller.minimized, isFalse);
        await tester.drag(find.byType(ListView), const Offset(0, -250));
        await tester.pumpAndSettle();
        expect(controller.minimized, isTrue);
      },
    );

    // 11. Controller minimize() and expand() methods unchanged
    testWidgets('Controller minimize() and expand() still operate directly', (
      tester,
    ) async {
      final controller = LiquidTabBarController();
      expect(controller.minimized, isFalse);

      controller.minimize();
      expect(controller.minimized, isTrue);

      controller.expand();
      expect(controller.minimized, isFalse);
    });

    // 12. True zero-controller end-to-end auto-folding without explicit controller
    testWidgets(
      'True zero-controller: LiquidTabBarScaffold automatically collapses and expands visible surface geometry',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: LiquidTabBarScaffold(
              tabBar: LiquidTabBar(
                shrinkOnScroll: true,
                selectedIndex: 0,
                items: sampleItems(),
              ),
              body: ListView.builder(
                itemCount: 100,
                itemBuilder: (_, i) =>
                    SizedBox(height: 60, child: Text('Zero-Config Item $i')),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaceClipFinder = find
            .descendant(
              of: find.byType(LiquidTabBar),
              matching: find.byType(ClipRRect),
            )
            .first;

        // 1. Initially expanded geometry: 3 tabs = 274 pt width
        final initialWidth = tester.getSize(surfaceClipFinder).width;
        expect(initialWidth, greaterThan(200.0));
        expect(find.text('Profile'), findsOneWidget);

        // 2. Drag downward (-300) to trigger automatic folding
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pumpAndSettle();

        // 3. Surface geometry collapsed to compact pill (64 pt circular capsule)
        final foldedWidth = tester.getSize(surfaceClipFinder).width;
        expect(foldedWidth, equals(64.0));
        expect(foldedWidth, lessThan(initialWidth));

        // 4. Drag upward (+300) to expand back
        await tester.drag(find.byType(ListView), const Offset(0, 300));
        await tester.pumpAndSettle();

        // 5. Surface geometry restored to full expanded width
        final expandedWidth = tester.getSize(surfaceClipFinder).width;
        expect(expandedWidth, equals(initialWidth));
      },
    );

    // 13. Two independent LiquidTabBarScaffolds without explicit controllers do not leak state
    testWidgets(
      'Two independent LiquidTabBarScaffolds without controllers isolate folding and search state',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Expanded(
                  child: LiquidTabBarScaffold(
                    tabBar: LiquidTabBar(
                      key: const ValueKey('barA'),
                      shrinkOnScroll: true,
                      selectedIndex: 0,
                      items: sampleItems(),
                    ),
                    body: ListView.builder(
                      key: const ValueKey('listA'),
                      itemCount: 80,
                      itemBuilder: (_, i) =>
                          SizedBox(height: 60, child: Text('Screen A Item $i')),
                    ),
                  ),
                ),
                Expanded(
                  child: LiquidTabBarScaffold(
                    tabBar: LiquidTabBar(
                      key: const ValueKey('barB'),
                      shrinkOnScroll: true,
                      selectedIndex: 0,
                      items: sampleItems(),
                    ),
                    body: ListView.builder(
                      key: const ValueKey('listB'),
                      itemCount: 80,
                      itemBuilder: (_, i) =>
                          SizedBox(height: 60, child: Text('Screen B Item $i')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final surfaceA = find
            .descendant(
              of: find.byKey(const ValueKey('barA')),
              matching: find.byType(ClipRRect),
            )
            .first;
        final surfaceB = find
            .descendant(
              of: find.byKey(const ValueKey('barB')),
              matching: find.byType(ClipRRect),
            )
            .first;

        final initialWidthA = tester.getSize(surfaceA).width;
        final initialWidthB = tester.getSize(surfaceB).width;
        expect(initialWidthA, greaterThan(200.0));
        expect(initialWidthB, greaterThan(200.0));

        // Scroll ONLY Screen A
        await tester.drag(
          find.byKey(const ValueKey('listA')),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        // Screen A folded to 64 pt; Screen B remains expanded!
        expect(tester.getSize(surfaceA).width, equals(64.0));
        expect(tester.getSize(surfaceB).width, equals(initialWidthB));

        // Scroll Screen A back up
        await tester.drag(
          find.byKey(const ValueKey('listA')),
          const Offset(0, 300),
        );
        await tester.pumpAndSettle();

        expect(tester.getSize(surfaceA).width, equals(initialWidthA));
        expect(tester.getSize(surfaceB).width, equals(initialWidthB));
      },
    );
  });

  group('LiquidTabBarScaffold Governor Inheritance & Controller Ownership', () {
    testWidgets(
      'A: shared governor not armed -> internal controller remains unarmed',
      (tester) async {
        expect(LiquidTabBarController.shared.isGovernorArmed, isFalse);

        await tester.pumpWidget(buildApp(body: const SizedBox()));
        await tester.pumpAndSettle();

        final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
        expect(bar.controller, isNotNull);
        expect(bar.controller!.isGovernorArmed, isFalse);
      },
    );

    testWidgets(
      'B: shared governor armed before creation -> internal controller is armed',
      (tester) async {
        LiquidTabBarController.shared.armGovernor();
        addTearDown(LiquidControllerTestOverrides.resetSharedGovernor);

        expect(LiquidTabBarController.shared.isGovernorArmed, isTrue);

        await tester.pumpWidget(buildApp(body: const SizedBox()));
        await tester.pumpAndSettle();

        final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
        expect(bar.controller, isNotNull);
        expect(bar.controller!.isGovernorArmed, isTrue);
        // Verify it is NOT identical to shared (it is an isolated instance that inherited the armed state)
        expect(
          identical(bar.controller, LiquidTabBarController.shared),
          isFalse,
        );
      },
    );

    testWidgets(
      'C: two zero-controller scaffolds own independent controller instances',
      (tester) async {
        LiquidTabBarController.shared.armGovernor();
        addTearDown(LiquidControllerTestOverrides.resetSharedGovernor);

        await tester.pumpWidget(
          MaterialApp(
            home: Column(
              children: [
                Expanded(
                  child: LiquidTabBarScaffold(
                    tabBar: LiquidTabBar(
                      key: const ValueKey('bar1'),
                      selectedIndex: 0,
                      items: sampleItems(),
                    ),
                    body: const SizedBox(),
                  ),
                ),
                Expanded(
                  child: LiquidTabBarScaffold(
                    tabBar: LiquidTabBar(
                      key: const ValueKey('bar2'),
                      selectedIndex: 0,
                      items: sampleItems(),
                    ),
                    body: const SizedBox(),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        final bar1 = tester.widget<LiquidTabBar>(
          find.byKey(const ValueKey('bar1')),
        );
        final bar2 = tester.widget<LiquidTabBar>(
          find.byKey(const ValueKey('bar2')),
        );

        expect(bar1.controller, isNotNull);
        expect(bar2.controller, isNotNull);
        expect(identical(bar1.controller, bar2.controller), isFalse);
        expect(bar1.controller!.isGovernorArmed, isTrue);
        expect(bar2.controller!.isGovernorArmed, isTrue);

        // Mutating one controller does not affect the other
        bar1.controller!.minimize();
        expect(bar1.controller!.minimized, isTrue);
        expect(bar2.controller!.minimized, isFalse);
      },
    );

    testWidgets(
      'D: explicit controller remains authoritative and is NOT automatically armed',
      (tester) async {
        LiquidTabBarController.shared.armGovernor();
        addTearDown(LiquidControllerTestOverrides.resetSharedGovernor);

        final explicit = LiquidTabBarController();
        addTearDown(explicit.dispose);
        expect(explicit.isGovernorArmed, isFalse);

        await tester.pumpWidget(
          buildApp(controller: explicit, body: const SizedBox()),
        );
        await tester.pumpAndSettle();

        final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
        expect(bar.controller, equals(explicit));
        expect(explicit.isGovernorArmed, isFalse);
      },
    );

    testWidgets(
      'E: explicit controller manually armed remains armed and works',
      (tester) async {
        expect(LiquidTabBarController.shared.isGovernorArmed, isFalse);

        final explicit = LiquidTabBarController()..armGovernor();
        addTearDown(explicit.dispose);
        expect(explicit.isGovernorArmed, isTrue);

        await tester.pumpWidget(
          buildApp(controller: explicit, body: const SizedBox()),
        );
        await tester.pumpAndSettle();

        final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
        expect(bar.controller, equals(explicit));
        expect(explicit.isGovernorArmed, isTrue);
      },
    );

    testWidgets(
      'F: disposal ownership correctly disposes internal controller but not explicit',
      (tester) async {
        // 1. Zero-controller scaffold: internal controller is disposed on unmount
        await tester.pumpWidget(buildApp(body: const SizedBox()));
        await tester.pumpAndSettle();

        final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
        final internal = bar.controller!;
        expect(internal.isDisposed, isFalse);

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pumpAndSettle();
        expect(internal.isDisposed, isTrue);

        // 2. Explicit controller scaffold: explicit controller is NOT disposed on unmount
        final explicit = LiquidTabBarController();
        addTearDown(explicit.dispose);
        await tester.pumpWidget(
          buildApp(controller: explicit, body: const SizedBox()),
        );
        await tester.pumpAndSettle();

        expect(explicit.isDisposed, isFalse);

        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        await tester.pumpAndSettle();
        expect(explicit.isDisposed, isFalse);
      },
    );
  });

  group('LiquidTabBar Lifecycle & Rapid Mount/Unmount Stress', () {
    testWidgets(
      '50 repeated mount, interact, scroll, fold, search, unmount cycles',
      (tester) async {
        LiquidTabBarController.shared.armGovernor();
        addTearDown(LiquidControllerTestOverrides.resetSharedGovernor);

        for (int i = 0; i < 50; i++) {
          final useExplicit = i % 2 == 0;
          final explicitController =
              useExplicit ? LiquidTabBarController() : null;

          await tester.pumpWidget(
            MaterialApp(
              home: LiquidTabBarScaffold(
                tabBar: LiquidTabBar(
                  controller: explicitController,
                  selectedIndex: i % 3,
                  items: sampleItems(),
                  separateAction: LiquidTabAction.search(onTap: () {}),
                ),
                body: ListView.builder(
                  itemCount: 50,
                  itemBuilder: (_, idx) =>
                      SizedBox(height: 50, child: Text('Row $idx')),
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16));

          // Scroll down to trigger fold
          await tester.drag(find.byType(ListView), const Offset(0, -100));
          await tester.pump(const Duration(milliseconds: 16));

          // Open search on some iterations
          if (i % 3 == 0) {
            final bar = tester.widget<LiquidTabBar>(find.byType(LiquidTabBar));
            bar.controller?.openSearch();
            await tester.pump(const Duration(milliseconds: 16));
          }

          // Unmount immediately mid-animation
          await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
          await tester.pump(const Duration(milliseconds: 16));

          explicitController?.dispose();
        }

        await tester.pumpAndSettle();
      },
    );
  });
}
