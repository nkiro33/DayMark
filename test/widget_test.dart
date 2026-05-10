import 'package:daymark/app/daymark_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the main Daymark tabs and Daily screen sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    expect(find.text('Daily'), findsWidgets);
    expect(find.text('Activities'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('To do'), findsOneWidget);
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('Missed'), findsOneWidget);
    expect(find.text('Sleep: 7.5h'), findsOneWidget);
    expect(find.text('Make Bed'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Study'),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Study'), findsOneWidget);
    expect(find.text('+ Log'), findsOneWidget);
  });

  testWidgets('uses Add wording and planned cards for a future day', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final month = tomorrow.month.toString().padLeft(2, '0');
    final day = tomorrow.day.toString().padLeft(2, '0');

    await tester.tap(
      find.byKey(ValueKey('day-selector-${tomorrow.year}-$month-$day')),
    );
    await tester.pumpAndSettle();

    expect(find.text('+ Add'), findsOneWidget);
    expect(find.text('0 credits planned'), findsWidgets);
    expect(find.text('Planned'), findsWidgets);
    expect(find.text('Done'), findsNothing);
  });
}
