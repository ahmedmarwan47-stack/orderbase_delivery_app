import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orderbase_delivery_app/main.dart';

void main() {
  testWidgets('App boots without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const OrderbaseCourierApp());
    await tester.pump();
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
