import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/activity/presentation/activity_providers.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/home/presentation/home_providers.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_providers.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_providers.dart';

import '../../support/provider_harness.dart';

ProviderContainer _as(Persona? persona) {
  final container = containerAs(persona);
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('homeViewProvider', () {
    test('Lerato: loaded, with two cards', () async {
      final view = await _as(Persona.lerato).read(homeViewProvider.future);

      expect(view, isA<HomeLoaded>());
      expect((view as HomeLoaded).cards, hasLength(2));
    });

    test('Thandi: the empty state, not an empty list', () async {
      final view = await _as(Persona.thandi).read(homeViewProvider.future);

      expect(view, isA<HomeEmpty>());
    });

    test(
      'is a sealed type: a switch needs both cases and no default',
      () async {
        final view = await _as(Persona.sipho).read(homeViewProvider.future);

        // If a third case is ever added to HomeView, this stops compiling.
        final label = switch (view) {
          HomeEmpty() => 'empty',
          HomeLoaded(:final cards) => '${cards.length} cards',
        };
        expect(label, '2 cards');
      },
    );

    test('signing in as someone else changes the answer', () async {
      final container = _as(null); // signed out: nobody has any stokvel
      expect(await container.read(homeViewProvider.future), isA<HomeEmpty>());

      container
          .read(authProvider.notifier)
          .signInWithEmail('lerato@tallyvel.test');

      expect(await container.read(homeViewProvider.future), isA<HomeLoaded>());
    });
  });

  group('stokvelDetailViewProvider (a family: one state per stokvel id)', () {
    test('Lerato is a treasurer in Family', () async {
      final view = await _as(Persona.lerato)
          .read(stokvelDetailViewProvider(SeedWorld.familyId).future);

      expect(view, isA<TreasurerView>());
    });

    test(
      '...and an ordinary member in Work: the same person, another role',
      () async {
        final view = await _as(Persona.lerato)
            .read(stokvelDetailViewProvider(SeedWorld.workId).future);

        expect(view, isA<MemberView>());
      },
    );

    test('Sipho is the reverse: Member in Family, treasurer in Work', () async {
      final container = _as(Persona.sipho);

      expect(
        await container.read(
          stokvelDetailViewProvider(SeedWorld.familyId).future,
        ),
        isA<MemberView>(),
      );
      expect(
        await container.read(
          stokvelDetailViewProvider(SeedWorld.workId).future,
        ),
        isA<TreasurerView>(),
      );
    });

    test('Thandi: not a member, so "not found"', () async {
      final view = await _as(Persona.thandi)
          .read(stokvelDetailViewProvider(SeedWorld.familyId).future);

      expect(view, isA<StokvelNotFound>());
    });

    test('an id that does not exist is the same "not found"', () async {
      final view = await _as(Persona.lerato)
          .read(stokvelDetailViewProvider('no-such-stokvel').future);

      expect(view, isA<StokvelNotFound>());
    });

    test('carries the cycle and the first page of contributions', () async {
      final view = await _as(Persona.lerato).read(
        stokvelDetailViewProvider(SeedWorld.familyId).future,
      ) as StokvelContent;

      expect(view.cycles, hasLength(1));
      expect(view.contributions.items, hasLength(4));
      expect(view.detail.name, 'Family Stokvel');
    });

    test('each id has its own state', () async {
      final container = _as(Persona.lerato);
      final family = await container.read(
        stokvelDetailViewProvider(SeedWorld.familyId).future,
      );
      final work = await container.read(
        stokvelDetailViewProvider(SeedWorld.workId).future,
      );

      expect((family as StokvelContent).detail.name, 'Family Stokvel');
      expect((work as StokvelContent).detail.name, 'Work Stokvel');
    });

    test('the switch over all three cases needs no default', () async {
      final view = await _as(Persona.lerato)
          .read(stokvelDetailViewProvider(SeedWorld.familyId).future);

      final label = switch (view) {
        StokvelNotFound() => 'not found',
        MemberView() => 'member',
        TreasurerView() => 'treasurer',
      };
      expect(label, 'treasurer');
    });
  });

  group('the other providers', () {
    test("myStokvels lists the person's stokvels", () async {
      final list = await _as(Persona.lerato).read(myStokvelsProvider.future);

      expect(list.map((s) => s.name), ['Family Stokvel', 'Work Stokvel']);
    });

    test('activityFeed is the first page', () async {
      final page = await _as(Persona.lerato).read(activityFeedProvider.future);

      expect(page.items, isNotEmpty);
    });
  });
}
