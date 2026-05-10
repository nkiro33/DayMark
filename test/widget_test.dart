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

  testWidgets('logs an unlogged duration activity from the Daily screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity-card-activity-exercise')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -140));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('log-action-activity-exercise')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('30 min'));
    await tester.pumpAndSettle();

    expect(find.text('Partial'), findsWidgets);
    expect(find.text('3 credits'), findsOneWidget);
  });

  testWidgets('updates sleep and adds a one-time activity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.tap(find.text('Sleep: 7.5h'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('8 hours'));
    await tester.pumpAndSettle();

    expect(find.text('Sleep: 8h'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('daily-primary-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create one-time activity'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('one-time-title-field')),
      'Call family',
    );
    await tester.tap(find.byKey(const ValueKey('save-one-time-activity')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Call family'),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Call family'), findsOneWidget);
  });
}
