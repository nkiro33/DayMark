import 'package:daymark/app/daymark_app.dart';
import 'package:daymark/app/daymark_settings.dart';
import 'package:daymark/features/activities/activities_screen.dart';
import 'package:daymark/features/daily/activity_form_result.dart';
import 'package:daymark/features/daily/widgets/activity_form_sheet.dart';
import 'package:daymark/features/settings/settings_screen.dart';
import 'package:daymark/models/models.dart';
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
    expect(find.byKey(const ValueKey('daily-primary-action')), findsOneWidget);
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

    expect(find.byTooltip('Add activity'), findsOneWidget);
    expect(find.textContaining('0 credits planned'), findsWidgets);
    expect(find.textContaining('Planned'), findsWidgets);
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

    expect(find.textContaining('Completed'), findsWidgets);
    expect(find.textContaining('3 credits'), findsOneWidget);
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

    expect(find.textContaining('8 credits'), findsWidgets);
  });

  testWidgets('previews log credits before saving details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity-card-activity-reduce-tiktok-reels')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reduce TikTok/Reels').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('-2 credits'), findsWidgets);

    await tester.tap(find.text('Bad day'));
    await tester.pumpAndSettle();

    expect(find.textContaining('-5 credits'), findsWidgets);
    expect(find.text('Reduce TikTok/Reels updated.'), findsNothing);
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
    expect(find.textContaining('1 credits'), findsOneWidget);
  });

  testWidgets('shows activity management cards and pauses an activity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ActivitiesScreen()));

    expect(find.text('New Activity'), findsOneWidget);
    expect(find.text('Good Habits'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('activity-management-card-activity-make-bed')),
      findsOneWidget,
    );
    await tester.tap(find.text('Make Bed'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Pause Activity'),
      120,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Pause Activity'));
    await tester.pumpAndSettle();

    expect(find.text('Make Bed paused.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('activity-management-card-activity-make-bed')),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.byKey(const ValueKey('activity-management-card-activity-make-bed')),
      findsOneWidget,
    );
    expect(find.text('Inactive'), findsWidgets);
  });

  testWidgets('creates a reusable activity from the Activities screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ActivitiesScreen()));

    await tester.tap(find.byKey(const ValueKey('activities-new-activity')));
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

    expect(find.text('Read added.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Read'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Read'), findsOneWidget);
  });

  testWidgets('activity form uses good or bad and supports custom category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ActivitiesScreen()));

    await tester.tap(find.byKey(const ValueKey('activities-new-activity')));
    await tester.pumpAndSettle();

    expect(find.text('Good Habit'), findsOneWidget);
    expect(find.text('Bad Habit'), findsOneWidget);
    expect(find.text('Track'), findsNothing);
    expect(find.byKey(const ValueKey('cancel-activity-form')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('recurring-title-field')),
      'Practice piano',
    );
    await tester.tap(find.byKey(const ValueKey('category-menu-field')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(MenuItemButton, 'Create new category'),
      80,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(
      find.widgetWithText(MenuItemButton, 'Create new category'),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('custom-category-field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('custom-category-field')),
      'Music',
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-recurring-activity')),
      300,
      scrollable: _activityFormScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-recurring-activity')));
    await tester.pumpAndSettle();

    expect(find.text('Practice piano added.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Practice piano'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Music'), findsOneWidget);
  });

  testWidgets('activity form hides type when category defines it', (
    WidgetTester tester,
  ) async {
    ActivityFormResult? savedResult;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActivityFormSheet(
            title: 'New Activity',
            submitLabel: 'Save',
            categories: _formTestCategories,
            isRecurring: true,
            initialCategoryId: 'category-personal',
            onSave: (result) => savedResult = result,
          ),
        ),
      ),
    );

    expect(find.text('Good Habit'), findsOneWidget);
    expect(find.text('Bad Habit'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('category-menu-field')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Good Habit'));
    await tester.pumpAndSettle();

    expect(find.text('Bad Habit'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('recurring-title-field')),
      'Make tea',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-recurring-activity')),
      300,
      scrollable: _activityFormScrollable,
    );
    await tester.tap(find.byKey(const ValueKey('save-recurring-activity')));
    await tester.pumpAndSettle();

    expect(savedResult?.activityType, ActivityType.positive);
  });

  testWidgets(
    'activity form converts duration credits per hour to per minute',
    (WidgetTester tester) async {
      ActivityFormResult? savedResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityFormSheet(
              title: 'New Activity',
              submitLabel: 'Save',
              categories: _formTestCategories,
              isRecurring: true,
              initialCategoryId: 'category-personal',
              initialTrackingType: TrackingType.duration,
              onSave: (result) => savedResult = result,
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byKey(const ValueKey('recurring-title-field')),
        'Practice guitar',
      );

      await tester.scrollUntilVisible(
        find.text('Per hour'),
        300,
        scrollable: _activityFormScrollable,
      );
      await tester.drag(_activityFormScrollable, const Offset(0, -140));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Per hour'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('duration-credit-field')),
        '12',
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('save-recurring-activity')),
        300,
        scrollable: _activityFormScrollable,
      );
      await tester.tap(find.byKey(const ValueKey('save-recurring-activity')));
      await tester.pumpAndSettle();

      expect(savedResult?.creditPerMinute, closeTo(0.2, 0.0001));
    },
  );

  testWidgets('shows presaved templates and keeps search inside the tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ActivitiesScreen()));

    await tester.enterText(find.byType(SearchBar), 'Drink');
    await tester.pumpAndSettle();

    expect(find.text('Drink Water'), findsOneWidget);

    await tester.enterText(find.byType(SearchBar), '');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Good Habits'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'study');
    await tester.pumpAndSettle();

    expect(find.text('No matching activities.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('activity-management-card-activity-study')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('presaved-template-card-template-study')),
      findsNothing,
    );
  });

  testWidgets('uses a presaved template as an editable activity', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ActivitiesScreen()));

    await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Health'));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Health'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar), 'Drink');
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(
          const ValueKey('presaved-template-card-template-drink-water'),
        ),
        matching: find.text('Use Template'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('recurring-title-field')), findsOneWidget);
    expect(find.text('Drink Water'), findsWidgets);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('save-recurring-activity')),
      300,
      scrollable: _activityFormScrollable,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-recurring-activity')));
    await tester.pumpAndSettle();

    expect(find.text('Drink Water added.'), findsOneWidget);
  });

  testWidgets('shows MVP settings sections and updates preferences', (
    WidgetTester tester,
  ) async {
    final settings = DaymarkSettings();
    await tester.pumpWidget(
      MaterialApp(home: SettingsScreen(settings: settings)),
    );

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);

    await tester.tap(find.text('Theme'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(find.text('Light'), findsOneWidget);
    expect(settings.themePreference, DaymarkThemePreference.light);

    await tester.tap(find.byKey(const ValueKey('daily-reminder-switch')));
    await tester.pumpAndSettle();

    expect(find.textContaining('9:00'), findsWidgets);
    expect(settings.dailyReminderEnabled, isTrue);

    await tester.scrollUntilVisible(
      find.text('Reflections'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Reflections'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Scoring'),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Scoring'), findsOneWidget);
    expect(find.text('Data'), findsNothing);
  });

  testWidgets('daily score setting hides score on the Daily screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaymarkApp());

    expect(find.textContaining('credits'), findsWidgets);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('daily-score-switch')),
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -160));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('daily-score-switch')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.today_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Daily score hidden'), findsOneWidget);
    expect(find.textContaining('credits'), findsNothing);
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

const _formTestCategories = [
  ActivityCategory(
    id: 'category-good-habit',
    name: 'Good Habit',
    code: 'good_habit',
  ),
  ActivityCategory(
    id: 'category-bad-habit',
    name: 'Bad Habit',
    code: 'bad_habit',
  ),
  ActivityCategory(id: 'category-personal', name: 'Personal', code: 'personal'),
];
