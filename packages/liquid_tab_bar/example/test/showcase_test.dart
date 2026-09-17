import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/droplet.dart';
import 'package:liquid_tab_bar_example/main.dart';
import 'package:liquid_tab_bar_example/examples/basic_example.dart';
import 'package:liquid_tab_bar_example/examples/actions_example.dart';
import 'package:liquid_tab_bar_example/examples/advanced_example.dart';

void main() {
  testWidgets('launcher boots with four demos', (tester) async {
    await tester.pumpWidget(const LiquidTabBarExampleApp());
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('Basic'), findsOneWidget);
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
}
