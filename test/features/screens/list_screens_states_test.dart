import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';
import 'package:tallyvel/features/activity/presentation/activity_screen.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_screen.dart';

import '../../support/provider_harness.dart';
import '../../support/pump_with.dart';
import '../../support/stubs.dart';

StubStokvelsRepository _stokvels(Future<List<Stokvel>> Function() onMine) =>
    StubStokvelsRepository(onMine: onMine, onDetail: (_, _) async => null);

void main() {
  group('the Stokvels tab, one test per state', () {
    Future<void> pumpTab(
      WidgetTester tester,
      Future<List<Stokvel>> Function() onMine,
    ) => pumpWith(
      tester,
      const StokvelsScreen(),
      overrides: [
        stokvelsRepositoryProvider.overrideWithValue(_stokvels(onMine)),
      ],
    );

    testWidgets('loading', (tester) async {
      await pumpTab(tester, () => Completer<List<Stokvel>>().future);
      await tester.pump();

      expect(find.byKey(const Key('loading')), findsOneWidget);
    });

    testWidgets('empty', (tester) async {
      await pumpTab(tester, () async => const []);
      await tester.pump();

      expect(find.byKey(const Key('stokvels-empty')), findsOneWidget);
    });

    testWidgets('data: both stokvels with the amount and member count', (
      tester,
    ) async {
      await pumpWith(
        tester,
        const StokvelsScreen(),
        overrides: fakeWorldAs(Persona.lerato),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('stokvel-${SeedWorld.familyId}')), findsOne);
      expect(find.byKey(const Key('stokvel-${SeedWorld.workId}')), findsOne);
      expect(find.textContaining('R500,00 · 4 members'), findsOneWidget);
    });

    testWidgets('failure, with Try again', (tester) async {
      await pumpTab(tester, () => Future.error(Exception('offline')));
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsOneWidget);
      expect(find.byKey(const Key('retry')), findsOneWidget);
    });
  });

  group('the Activity tab, one test per state', () {
    testWidgets('data: who paid what', (tester) async {
      await pumpWith(
        tester,
        const ActivityScreen(),
        overrides: fakeWorldAs(Persona.lerato),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Lindiwe Dube paid R0,10'), findsOneWidget);
      expect(find.text('Sipho Zulu joined'), findsWidgets);
    });

    testWidgets('empty: Thandi has no stokvel, so nothing has happened', (
      tester,
    ) async {
      await pumpWith(
        tester,
        const ActivityScreen(),
        overrides: fakeWorldAs(Persona.thandi),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('activity-empty')), findsOneWidget);
    });

    testWidgets('failure, with Try again', (tester) async {
      await pumpWith(
        tester,
        const ActivityScreen(),
        overrides: [
          activityRepositoryProvider.overrideWithValue(
            StubActivityRepository(
              () => Future<PageOf<ActivityItem>>.error(Exception('offline')),
            ),
          ),
        ],
      );
      await tester.pump();

      expect(find.byKey(const Key('failure')), findsOneWidget);
    });
  });
}
