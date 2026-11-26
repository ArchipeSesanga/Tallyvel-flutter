import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_screen.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

import '../../support/provider_harness.dart';
import '../../support/pump_with.dart';
import '../../support/stubs.dart';

Future<void> _pumpDetail(
  WidgetTester tester,
  String stokvelId, {
  required Persona persona,
  StubStokvelsRepository? stokvels,
}) => pumpWith(
  tester,
  StokvelDetailScreen(stokvelId: stokvelId),
  overrides: [...fakeWorldAs(persona, stokvels: stokvels)],
);

void main() {
  group('a stokvel page, one test per state', () {
    testWidgets('loading: a spinner, no stokvel name yet', (tester) async {
      final stokvels = StubStokvelsRepository(
        onMine: () async => const [],
        onDetail: (_, _) => Completer<StokvelDetail?>().future,
      );
      await _pumpDetail(
        tester,
        SeedWorld.familyId,
        persona: Persona.lerato,
        stokvels: stokvels,
      );
      await tester.pump();

      expect(find.byKey(const Key('loading')), findsOneWidget);
      expect(find.text('Family Stokvel'), findsNothing);
    });

    testWidgets('not found: "Not found", for a stokvel she is not in', (
      tester,
    ) async {
      await _pumpDetail(tester, SeedWorld.familyId, persona: Persona.thandi);
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('not-found')), findsOneWidget);
      expect(find.text('Not found'), findsOneWidget);
      expect(find.byKey(const Key('actions')), findsNothing);
    });

    testWidgets('not found: a made-up id looks exactly the same', (
      tester,
    ) async {
      await _pumpDetail(tester, 'no-such-stokvel', persona: Persona.lerato);
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('not-found')), findsOneWidget);
      expect(find.text('Not found'), findsOneWidget);
    });

    testWidgets('data: the stokvel, its cycle and its contributions', (
      tester,
    ) async {
      await _pumpDetail(tester, SeedWorld.familyId, persona: Persona.lerato);
      await tester.pump();
      await tester.pump();

      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(
        find.textContaining('R1\u00A0000,10 of R2\u00A0000,00 collected'),
        findsOneWidget,
      );
      expect(find.text('Lindiwe Dube'), findsOneWidget);
      expect(find.text('R0,10'), findsOneWidget);
    });

    testWidgets('failure: a message and Try again, which works', (
      tester,
    ) async {
      final world = SeedWorld(now: testNow);
      final stokvels = StubStokvelsRepository(
        onMine: () async => const [],
        onDetail: (_, call) => call == 1
            ? Future.error(Exception('offline'))
            : Future.value(world.detail(world.stokvels.first)),
      );
      await _pumpDetail(
        tester,
        SeedWorld.familyId,
        persona: Persona.lerato,
        stokvels: stokvels,
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsOneWidget);

      await tester.tap(find.byKey(const Key('retry')));
      await tester.pump();
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsNothing);
      expect(find.text('Family Stokvel'), findsOneWidget);
    });
  });

  group('what the person can do, as a role in THIS stokvel', () {
    Future<void> open(WidgetTester tester, String id, Persona persona) async {
      await _pumpDetail(tester, id, persona: persona);
      await tester.pump();
      await tester.pump();
    }

    testWidgets('Lerato is Treasurer in Family: the treasurer actions', (
      tester,
    ) async {
      await open(tester, SeedWorld.familyId, Persona.lerato);

      expect(find.byKey(const Key('action-closeCycle')), findsOneWidget);
      expect(find.byKey(const Key('action-payOut')), findsOneWidget);
      expect(find.byKey(const Key('action-recordForMember')), findsOneWidget);
      // Her own R500 is Pending: she already has a contribution, so she
      // cannot record another.
      expect(
        find.byKey(const Key('action-recordMyContribution')),
        findsNothing,
      );
    });

    testWidgets('...and an ordinary member in Work who has paid: nothing', (
      tester,
    ) async {
      await open(tester, SeedWorld.workId, Persona.lerato);

      expect(find.text('Work Stokvel'), findsOneWidget);
      expect(find.byKey(const Key('actions')), findsNothing);
    });

    testWidgets('Sipho is the other way round', (tester) async {
      await open(tester, SeedWorld.familyId, Persona.sipho);
      expect(find.byKey(const Key('actions')), findsNothing);
      expect(find.text('Family Stokvel'), findsOneWidget);

      await open(tester, SeedWorld.workId, Persona.sipho);
      expect(find.byKey(const Key('action-closeCycle')), findsOneWidget);
      // He has no contribution in Work yet, so he may record his own.
      expect(
        find.byKey(const Key('action-recordMyContribution')),
        findsOneWidget,
      );
    });

    testWidgets('the contributions show names, statuses and amounts', (
      tester,
    ) async {
      await open(tester, SeedWorld.familyId, Persona.lerato);

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Paid'), findsNWidgets(2));
    });
  });
}
