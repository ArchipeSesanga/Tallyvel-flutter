import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/presentation/home_screen.dart';

import '../../support/provider_harness.dart';
import '../../support/pump_with.dart';
import '../../support/stubs.dart';

List<HomeCard> _leratoCards() {
  final world = SeedWorld(now: testNow);
  return [
    for (final s in world.stokvelsOf(SeedWorld.leratoId))
      world.cardFor(SeedWorld.leratoId, s),
  ];
}

Future<StubHomeRepository> _pump(
  WidgetTester tester,
  Future<List<HomeCard>> Function(int call) onCards,
) async {
  final repo = StubHomeRepository(onCards);
  await pumpWith(
    tester,
    const HomeScreen(),
    overrides: [homeRepositoryProvider.overrideWithValue(repo)],
  );
  return repo;
}

void main() {
  group('Home, one test per state', () {
    testWidgets('loading: a spinner and no cards', (tester) async {
      await _pump(tester, (_) => Completer<List<HomeCard>>().future);
      await tester.pump();

      expect(find.byKey(const Key('loading')), findsOneWidget);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('empty: says what to do next', (tester) async {
      await _pump(tester, (_) async => const []);
      await tester.pump();

      expect(find.byKey(const Key('home-empty')), findsOneWidget);
      expect(find.text("You're not in a stokvel yet."), findsOneWidget);
      expect(
        find.textContaining('ask a member to send you an invite'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('loading')), findsNothing);
    });

    testWidgets('data: a card per stokvel with the role and the numbers', (
      tester,
    ) async {
      await _pump(tester, (_) async => _leratoCards());
      await tester.pump();

      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(find.text('Work Stokvel'), findsOneWidget);
      expect(find.text('Treasurer'), findsOneWidget);
      expect(find.text('Member'), findsOneWidget);
      expect(find.textContaining('Owe R500,00'), findsOneWidget);
    });

    testWidgets('failure: a message and Try again, which works', (
      tester,
    ) async {
      await _pump(
        tester,
        (call) => call == 1
            ? Future.error(Exception('offline'))
            : Future.value(_leratoCards()),
      );
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.byType(Card), findsNothing);

      await tester.tap(find.byKey(const Key('retry')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsNothing);
      expect(find.text('Family Stokvel'), findsOneWidget);
    });
  });

  group('pull to refresh', () {
    testWidgets('keeps the old cards on screen while it reloads', (
      tester,
    ) async {
      final reload = Completer<List<HomeCard>>();
      final repo = await _pump(
        tester,
        (call) => call == 1 ? Future.value(_leratoCards()) : reload.future,
      );
      await tester.pump();
      expect(find.text('Family Stokvel'), findsOneWidget);

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Reloading: the cards are STILL there, and so is a progress bar.
      expect(repo.calls, 2);
      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(find.text('Work Stokvel'), findsOneWidget);
      expect(find.byKey(const Key('refreshing')), findsOneWidget);
      expect(find.byKey(const Key('loading')), findsNothing);

      reload.complete(_leratoCards().take(1).toList());
      await tester.pumpAndSettle();

      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(find.text('Work Stokvel'), findsNothing);
      expect(find.byKey(const Key('refreshing')), findsNothing);
    });

    testWidgets('a failed refresh keeps the cards and says so', (tester) async {
      await _pump(
        tester,
        (call) => call == 1
            ? Future.value(_leratoCards())
            : Future.error(Exception('offline')),
      );
      await tester.pump();

      await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(find.byKey(const Key('refresh-failed')), findsOneWidget);
      expect(find.byKey(const Key('failure')), findsNothing);
    });
  });
}
