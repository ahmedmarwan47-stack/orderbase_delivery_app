import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';
import 'package:liquid_tab_bar_example/main.dart';
import 'package:liquid_tab_bar_example/examples/basic_example.dart';
import 'package:liquid_tab_bar_example/examples/actions_example.dart';
import 'package:liquid_tab_bar_example/examples/advanced_example.dart';
import 'package:liquid_tab_bar_example/examples/custom_icons_example.dart';

void main() {
  testWidgets('launcher boots with demos', (tester) async {
    await tester.pumpWidget(const LiquidTabBarExampleApp());
    expect(find.byType(ListTile), findsNWidgets(5));
    expect(find.text('Basic'), findsOneWidget);
    expect(find.text('Custom Icons Demo'), findsOneWidget);
  });
  testWidgets('basic selection updates', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasicExample()));
    await tester.pumpAndSettle();
    final bar = find.byKey(const ValueKey('basic-bar'));
    await tester.tapAt(
      tester.getCenter(
        find
            .descendant(of: bar, matching: find.byIcon(Icons.explore_outlined))
            .last,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<LiquidTabBar>(bar).selectedIndex, 1);
  });
  testWidgets('Together and Split configure real placement', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ActionsExample()));
    await tester.pumpAndSettle();
    final bar = find.byKey(const ValueKey('actions-bar'));
    expect(
      tester.widget<LiquidTabBar>(bar).separateActionPlacement,
      LiquidTabActionPlacement.together,
    );
    await tester.tap(find.text('Split'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LiquidTabBar>(bar).separateActionPlacement,
      LiquidTabActionPlacement.split,
    );
  });
  testWidgets('advanced shape, RTL and search work', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AdvancedExample()));
    await tester.pumpAndSettle();
    final bar = find.byKey(const ValueKey('advanced-bar'));
    await tester.tap(find.text('Oval'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<LiquidTabBar>(bar).foldedShape,
      LiquidFoldedShape.oval,
    );
    await tester.tap(find.text('RTL / العربية'));
    await tester.pumpAndSettle();
    expect(Directionality.of(tester.element(bar)), TextDirection.rtl);
    await tester.tap(find.widgetWithText(TextButton, 'Search'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'ملاحظات');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'ملاحظات',
    );
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom icons demo renders and transitions correctly',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CustomIconsExample()));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsAtLeast(1));
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Favorite'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);

    await tester.tap(find.text('Explore'), warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ActionChip, 'Open Search'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.text('Icon Sizes (16/23/28px)'));
    await tester.pumpAndSettle();
    expect(find.text('Small'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Large'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
