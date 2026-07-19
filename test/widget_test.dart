import 'package:flutter_test/flutter_test.dart';

import 'package:wordleguesser_flutter/main.dart';

void main() {
  testWidgets('Onboarding shows on first run', (WidgetTester tester) async {
    await tester.pumpWidget(const WordleGuesserApp(showOnboarding: true));
    await tester.pump();
    expect(find.text('WORDLE\nGUESSER'), findsOneWidget);
  });
}
