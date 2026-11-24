import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/features/auth/domain/auth_repository.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';

import 'support/stubs.dart';

Future<void> _pump(
  WidgetTester tester,
  Map<String, Object> prefs, {
  AuthRepository? authRepository,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sp),
        authRepositoryProvider.overrideWithValue(
          authRepository ?? StubAuthRepository(),
        ),
      ],
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

  testWidgets('skips onboarding once completed and asks to sign in', (
    tester,
  ) async {
    await _pump(tester, {'onboarding_complete': true});
    expect(find.text('Every contribution, counted.'), findsNothing);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('signs in as Lerato, then signs out back to sign-in', (
    tester,
  ) async {
    await _pump(tester, {'onboarding_complete': true});

    await tester.tap(find.text('Lerato M.'));
    await tester.pump();
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      StubAuthRepository.password,
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Sign in'), findsNothing);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  Future<void> trySigningIn(WidgetTester tester) async {
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'lerato@tallyvel.test',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'whatever',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  testWidgets('a wrong password says so, and stays on sign-in', (tester) async {
    await _pump(tester, {'onboarding_complete': true});
    await trySigningIn(tester);

    expect(find.text('Wrong email or password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('too many tries tells the person how long to wait', (
    tester,
  ) async {
    await _pump(
      tester,
      {'onboarding_complete': true},
      authRepository: StubAuthRepository(
        failure: const RateLimitedFailure(retryAfterSeconds: 60),
      ),
    );
    await trySigningIn(tester);

    expect(find.text('Too many tries. Wait up to 60 seconds'), findsOneWidget);
  });

  testWidgets('no connection says so', (tester) async {
    await _pump(tester, {
      'onboarding_complete': true,
    }, authRepository: StubAuthRepository(failure: const NoAnswerFailure()));
    await trySigningIn(tester);

    expect(
      find.text("Can't reach TallyVel. Check your connection"),
      findsOneWidget,
    );
  });

  testWidgets('a server failure shows the reference to quote', (tester) async {
    await _pump(
      tester,
      {'onboarding_complete': true},
      authRepository: StubAuthRepository(
        failure: const ServerFailure(correlationId: 'abc123'),
      ),
    );
    await trySigningIn(tester);

    expect(find.textContaining('abc123'), findsOneWidget);
  });
}
