import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';

Future<void> _pump(WidgetTester tester, Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
      child: const TallyvelApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('walks through onboarding and remembers it', (tester) async {
    await _pump(tester, {});
    expect(find.text('Every contribution, counted.'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('See who has paid, at a glance.'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Everyone knows whose turn is next.'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('We keep the tally. You keep the money.'), findsOneWidget);

    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle();
    expect(find.text('How do you want to start?'), findsOneWidget);

    await tester.tap(find.text('Join with an invite'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Join my stokvel'));
    await tester.pumpAndSettle();

    expect(find.text('How do you want to start?'), findsNothing);
    final sp = await SharedPreferences.getInstance();
    expect(sp.getBool('onboarding_complete'), isTrue);
  });

  testWidgets('skip jumps to the start screen', (tester) async {
    await _pump(tester, {});
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('How do you want to start?'), findsOneWidget);
  });

  testWidgets('skips onboarding once completed', (tester) async {
    await _pump(tester, {'onboarding_complete': true});
    expect(find.text('Every contribution, counted.'), findsNothing);
    expect(find.text('Tallyvel'), findsOneWidget);
  });
}
