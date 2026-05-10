import 'package:daymark/app/daymark_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the main Daymark tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const DaymarkApp());

    expect(find.text('Daily'), findsWidgets);
    expect(find.text('Activities'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Ready to log your day?'), findsOneWidget);
  });
}
