import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tallyvel/app/app.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/activity/presentation/activity_screen.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/home/presentation/home_screen.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_screen.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_screen.dart';

import '../../support/provider_harness.dart';
import '../../support/pump_screen.dart';

void main() {
  testWidgets('the one-frame test: after sign-in, Home has its content one '
      'frame after the first build', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ...fakeWorldAs(Persona.lerato),
        ],
        child: const TallyvelApp(),
      ),
    );
    // Frame 1 shows the spinner. The fakes answer in a microtask, so exactly
    // one more frame, with no settling, is enough for real content.
    await tester.pump();

    expect(find.text('Family Stokvel'), findsOneWidget);
    expect(find.text('Work Stokvel'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  group('Home', () {
    testWidgets('Lerato sees her Treasurer card and her Member card', (
      tester,
    ) async {
      await pumpScreen(tester, const HomeScreen(), persona: Persona.lerato);

      final family = find.byKey(const Key('home-card-${SeedWorld.familyId}'));
      final work = find.byKey(const Key('home-card-${SeedWorld.workId}'));
      expect(
        find.descendant(of: family, matching: find.text('Treasurer')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: work, matching: find.text('Member')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: family,
          matching: find.textContaining('Owe R500,00'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: work,
          matching: find.textContaining('Paid R300,00 · Owe R0,00'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Due 30 Nov 2026'), findsNWidgets(2));
    });

    testWidgets('Thandi sees the empty state', (tester) async {
      await pumpScreen(tester, const HomeScreen(), persona: Persona.thandi);

      expect(find.byKey(const Key('home-empty')), findsOneWidget);
    });
  });

  group('a stokvel page', () {
    testWidgets('Lerato is a treasurer in Family: the actions show', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
        persona: Persona.lerato,
      );

      expect(find.byKey(const Key('treasurer-actions')), findsOneWidget);
      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(
        find.textContaining('R1 000,10 of R2 000,00 collected'),
        findsOneWidget,
      );
    });

    testWidgets('...and a member in Work: no treasurer actions', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.workId),
        persona: Persona.lerato,
      );

      expect(find.text('Work Stokvel'), findsOneWidget);
      expect(find.byKey(const Key('treasurer-actions')), findsNothing);
    });

    testWidgets('Sipho is the other way round', (tester) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
        persona: Persona.sipho,
      );
      expect(find.byKey(const Key('treasurer-actions')), findsNothing);

      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.workId),
        persona: Persona.sipho,
      );
      expect(find.byKey(const Key('treasurer-actions')), findsOneWidget);
    });

    testWidgets('the contributions show names, statuses and amounts', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
        persona: Persona.lerato,
      );

      expect(find.text('Lindiwe Dube'), findsOneWidget);
      expect(find.text('R0,10'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
    });

    testWidgets('Thandi gets "Not found" for a stokvel she is not in', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
        persona: Persona.thandi,
      );

      expect(find.byKey(const Key('not-found')), findsOneWidget);
      expect(find.byKey(const Key('treasurer-actions')), findsNothing);
    });

    testWidgets('a made-up id gets the same "Not found"', (tester) async {
      await pumpScreen(
        tester,
        const StokvelDetailScreen(stokvelId: 'no-such-stokvel'),
        persona: Persona.lerato,
      );

      expect(find.byKey(const Key('not-found')), findsOneWidget);
    });
  });

  testWidgets('the Stokvels tab lists the two stokvels', (tester) async {
    await pumpScreen(tester, const StokvelsScreen(), persona: Persona.lerato);

    expect(find.byKey(const Key('stokvel-${SeedWorld.familyId}')), findsOne);
    expect(find.byKey(const Key('stokvel-${SeedWorld.workId}')), findsOne);
  });

  testWidgets('the Activity tab tells who paid what', (tester) async {
    await pumpScreen(tester, const ActivityScreen(), persona: Persona.lerato);

    expect(find.text('Lindiwe Dube paid R0,10'), findsOneWidget);
    expect(find.text('Sipho Zulu joined'), findsWidgets);
  });
}
