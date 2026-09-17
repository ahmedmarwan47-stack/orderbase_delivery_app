import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/droplet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final items = [
    LiquidTabItem.icon(label: 'Home', icon: Icons.home),
    LiquidTabItem.icon(label: 'Radio', icon: Icons.radio),
    LiquidTabItem.icon(label: 'Library', icon: Icons.library_music),
  ];

  Future<void> pumpBar(
    WidgetTester tester, {
    required LiquidTabActionPlacement placement,
    double? maxWidth,
    LiquidDropletSurfaceStyle? dropletSurfaceStyle,
    LiquidTabBarMaterial material = LiquidTabBarMaterial.opaque,
  }) async {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: LiquidTabBar(
            items: items,
            selectedIndex: 0,
            material: material,
            maxWidth: maxWidth,
            separateAction: LiquidTabAction.icon(
              icon: Icons.search,
              tooltip: 'Search',
            ),
            separateActionPlacement: placement,
            theme: LiquidTabBarTheme(
              maxWidth: maxWidth,
              dropletSurfaceStyle:
                  dropletSurfaceStyle ?? LiquidDropletSurfaceStyle.light,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'custom maxWidth keeps together group centered on wide viewport',
    (tester) async {
      await pumpBar(
        tester,
        placement: LiquidTabActionPlacement.together,
        maxWidth: 500,
      );
      final centers = [
        tester.getCenter(find.byIcon(Icons.home)),
        tester.getCenter(find.byIcon(Icons.search)),
      ];
      final library = tester.getCenter(find.byIcon(Icons.library_music));
      // The icon centers sit inside the capsule/action surfaces; their midpoint
      // remains close to the viewport center even with the custom cap.
      expect((centers.first.dx + centers.last.dx) / 2, closeTo(600, 30));
      expect(library.dx - centers.first.dx, greaterThan(250));
    },
  );

  testWidgets('custom maxWidth preserves split leading/trailing placement', (
    tester,
  ) async {
    await pumpBar(
      tester,
      placement: LiquidTabActionPlacement.split,
      maxWidth: 500,
    );
    final tabX = tester.getCenter(find.byIcon(Icons.home)).dx;
    final actionX = tester.getCenter(find.byIcon(Icons.search)).dx;
    expect(tabX, lessThan(300));
    expect(actionX, greaterThan(900));
  });

  testWidgets('custom droplet surface style reaches opaque droplet', (
    tester,
  ) async {
    const custom = LiquidDropletSurfaceStyle(
      gradientTop: Color(0xFF123456),
      gradientBottom: Color(0xFF654321),
      borderColor: Color(0xFFABCDEF),
      shadow: BoxShadow(
        color: Color(0xFF101010),
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
      opaqueFill: Color(0xFFFF0000),
    );
    await pumpBar(
      tester,
      placement: LiquidTabActionPlacement.together,
      dropletSurfaceStyle: custom,
    );

    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>();
    expect(
      decorations.any(
        (decoration) => decoration.color?.r == custom.opaqueFill.r,
      ),
      isTrue,
    );
  });

  testWidgets('custom droplet surface style reaches blur droplet', (
    tester,
  ) async {
    const custom = LiquidDropletSurfaceStyle(
      gradientTop: Color(0xFF123456),
      gradientBottom: Color(0xFF654321),
      borderColor: Color(0xFFABCDEF),
      shadow: BoxShadow(
        color: Color(0xFF101010),
        blurRadius: 10,
        offset: Offset(0, 3),
      ),
      opaqueFill: Color(0xFFFF0000),
    );
    await pumpBar(
      tester,
      placement: LiquidTabActionPlacement.together,
      material: LiquidTabBarMaterial.blur,
      dropletSurfaceStyle: custom,
    );

    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration)
        .whereType<BoxDecoration>();
    expect(
      decorations.any(
        (decoration) =>
            decoration.gradient is LinearGradient &&
            (decoration.gradient! as LinearGradient).colors.first.r ==
                custom.gradientTop.r,
      ),
      isTrue,
    );
  });
}
