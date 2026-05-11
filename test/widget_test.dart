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
    expect(find.text('Sleep: 7h 30m'), findsOneWidget);
    expect(find.text('Make Bed'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity-card-activity-study')),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      find.byKey(const ValueKey('activity-card-activity-study')),
      findsOneWidget,
    );
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

    await tester.enterText(
      find.byKey(const ValueKey('duration-hours-field')),
      '0',
    );
    await tester.enterText(
      find.byKey(const ValueKey('duration-minutes-field')),
      '30',
    );
    await tester.tap(find.byKey(const ValueKey('save-duration-duration')));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsWidgets);
    expect(find.text('3 credits'), findsOneWidget);
  });

  testWidgets('shows encouraging empty copy for the Missed filter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.tap(find.widgetWithText(FilterChip, 'Missed'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing missed here.'), findsOneWidget);
    expect(find.text('That is a good sign.'), findsOneWidget);
    expect(find.text('+ Log Activity'), findsNothing);
  });

  testWidgets('opens log details from the card and saves a note', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.tap(
      find.byKey(const ValueKey('activity-card-activity-make-bed')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('daily-log-note-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('clear-daily-log')), findsOneWidget);
    expect(find.text('Done'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('daily-log-note-field')),
      'Started calmly.',
    );
    await tester.tap(find.byKey(const ValueKey('save-daily-log')));
    await tester.pumpAndSettle();

    expect(find.text('Make Bed updated.'), findsOneWidget);
  });

  testWidgets('edits duration from the log details sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity-card-activity-study')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Study').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('daily-log-duration-hours-field')),
      '1',
    );
    await tester.enterText(
      find.byKey(const ValueKey('daily-log-duration-minutes-field')),
      '30',
    );
    await tester.tap(find.byKey(const ValueKey('save-daily-log')));
    await tester.pumpAndSettle();

    expect(find.text('8 credits'), findsOneWidget);
  });

  testWidgets('keeps bad habits out of the To do filter', (
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
    await tester.tap(find.widgetWithText(FilterChip, 'To do'));
    await tester.pumpAndSettle();

    expect(find.text('Reduce TikTok/Reels'), findsNothing);
  });

  testWidgets('updates sleep and adds a one-time activity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.tap(find.text('Sleep: 7h 30m'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('sleep-hours-field')),
      '8',
    );
    await tester.enterText(
      find.byKey(const ValueKey('sleep-minutes-field')),
      '15',
    );
    await tester.enterText(
      find.byKey(const ValueKey('sleep-note-field')),
      'Slept deeply.',
    );
    await tester.tap(find.byKey(const ValueKey('save-sleep-duration')));
    await tester.pumpAndSettle();

    expect(find.text('Sleep: 8h 15m'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('daily-primary-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Create one-time activity'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('one-time-title-field')),
      'Call family',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-one-time-activity')),
      300,
      scrollable: _activityFormScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-one-time-activity')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Call family'),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Call family'), findsOneWidget);
  });

  testWidgets('adds a recurring activity from the Daily action sheet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.tap(find.byKey(const ValueKey('daily-primary-action')));
    await tester.pumpAndSettle();

    expect(find.text('Create recurring activity'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ListTile, 'Create recurring activity'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recurring-title-field')),
      'Read',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-recurring-activity')),
      300,
      scrollable: _activityFormScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-recurring-activity')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Read'),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Read'), findsOneWidget);
    expect(find.text('1 credits'), findsOneWidget);
  });
}

Finder get _activityFormScrollable {
  return find
      .descendant(
        of: find.byKey(const ValueKey('activity-form-scroll')),
        matching: find.byType(Scrollable),
      )
      .first;
}
