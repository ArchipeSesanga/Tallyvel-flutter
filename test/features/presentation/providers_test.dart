import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/features/activity/presentation/activity_providers.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/home/presentation/home_providers.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvel_detail/domain/stokvel_action.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_providers.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_providers.dart';

import '../../support/provider_harness.dart';
import '../../support/stubs.dart';

/// A fresh container for every test, never shared: no test can see another's
/// state, and nothing is left behind.
ProviderContainer _fresh(
  Persona? persona, {
  HomeRepository? home,
  StokvelsRepository? stokvels,
  List<Override> extra = const [],
}) {
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      ...fakeWorldAs(persona, home: home, stokvels: stokvels),
      ...extra,
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Records which providers were disposed, by name and family argument only:
/// ids, never names, amounts or anything else a person was shown.
base class _DisposeLog extends ProviderObserver {
  final List<String> lines = [];

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    final name = context.provider.name ?? '${context.provider.runtimeType}';
    final id = context.provider.argument;
    lines.add(id == null ? name : '$name($id)');
  }
}

StubStokvelsRepository _countingStokvels() {
  final world = SeedWorld(now: testNow);
  return StubStokvelsRepository(
    onMine: () async => const [],
    onDetail: (id, _) async => world.detail(world.stokvels.first),
  );
}

void main() {
  group('Home', () {
    test('Lerato: two cards', () async {
      final cards = await _fresh(Persona.lerato).read(homeProvider.future);

      expect(cards.map((c) => c.name), ['Family Stokvel', 'Work Stokvel']);
    });

    test('Thandi: no stokvels maps to Empty', () async {
      final container = _fresh(Persona.thandi);
      await container.read(homeProvider.future);

      expect(
        homeViewStateOf(container.read(homeProvider)),
        isA<ViewEmpty<List<HomeCard>>>(),
      );
    });

    test('refresh keeps the old cards in state while it reloads', () async {
      final world = SeedWorld(now: testNow);
      final cards = [world.cardFor(SeedWorld.leratoId, world.stokvels.first)];
      final reload = Completer<List<HomeCard>>();
      final repo = StubHomeRepository(
        (call) => call == 1 ? Future.value(cards) : reload.future,
      );
      final container = _fresh(Persona.lerato, home: repo);
      final sub = container.listen(homeProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(homeProvider.future);

      unawaited(container.read(homeProvider.notifier).refresh());
      await Future<void>.delayed(Duration.zero);

      final during = homeViewStateOf(container.read(homeProvider));
      expect(during, isA<ViewData<List<HomeCard>>>());
      expect((during as ViewData<List<HomeCard>>).value, cards);
      expect(during.isRefreshing, isTrue);

      reload.complete(const []);
      await container.read(homeProvider.future);
      expect(
        homeViewStateOf(container.read(homeProvider)),
        isA<ViewEmpty<List<HomeCard>>>(),
      );
    });

    test('signing in as someone else changes the answer', () async {
      final container = _fresh(
        null, // signed out: nobody has any stokvel
        extra: [authRepositoryProvider.overrideWithValue(StubAuthRepository())],
      );
      final sub = container.listen(homeProvider, (_, _) {});
      addTearDown(sub.close);
      expect(await container.read(homeProvider.future), isEmpty);

      await container
          .read(authProvider.notifier)
          .signIn(
            email: 'lerato@tallyvel.test',
            password: StubAuthRepository.password,
          );

      expect(await container.read(homeProvider.future), hasLength(2));
    });
  });

  group('the stokvel page is a family: one state per id', () {
    test('two ids are separate', () async {
      final container = _fresh(Persona.lerato);

      final family = await container.read(
        stokvelPageProvider(SeedWorld.familyId).future,
      );
      final work = await container.read(
        stokvelPageProvider(SeedWorld.workId).future,
      );

      expect(family!.detail.name, 'Family Stokvel');
      expect(work!.detail.name, 'Work Stokvel');
    });

    test('two listeners on one id share ONE fetch', () async {
      final stub = _countingStokvels();
      final container = _fresh(Persona.lerato, stokvels: stub);

      final a = container.listen(
        stokvelPageProvider(SeedWorld.familyId),
        (_, _) {},
      );
      final b = container.listen(
        stokvelPageProvider(SeedWorld.familyId),
        (_, _) {},
      );
      addTearDown(a.close);
      addTearDown(b.close);
      await container.read(stokvelPageProvider(SeedWorld.familyId).future);

      expect(stub.detailCalls, {SeedWorld.familyId: 1});
    });

    test('a different id is a different fetch', () async {
      final stub = _countingStokvels();
      final container = _fresh(Persona.lerato, stokvels: stub);

      await container.read(stokvelPageProvider(SeedWorld.familyId).future);
      await container.read(stokvelPageProvider(SeedWorld.workId).future);

      expect(stub.detailCalls, {SeedWorld.familyId: 1, SeedWorld.workId: 1});
    });

    test('a fresh container starts from nothing: no state is shared', () async {
      final first = _countingStokvels();
      final second = _countingStokvels();
      await _fresh(
        Persona.lerato,
        stokvels: first,
      ).read(stokvelPageProvider(SeedWorld.familyId).future);
      await _fresh(
        Persona.lerato,
        stokvels: second,
      ).read(stokvelPageProvider(SeedWorld.familyId).future);

      // The second container fetched again instead of reusing the first's.
      expect(first.detailCalls[SeedWorld.familyId], 1);
      expect(second.detailCalls[SeedWorld.familyId], 1);
    });

    test('the role comes from the membership for THIS stokvel', () async {
      final container = _fresh(Persona.lerato);

      final family = await container.read(
        stokvelPageProvider(SeedWorld.familyId).future,
      );
      final work = await container.read(
        stokvelPageProvider(SeedWorld.workId).future,
      );

      expect(family!.role, MemberRole.treasurer);
      expect(work!.role, MemberRole.member);
      expect(family.actions, contains(StokvelAction.closeCycle));
      expect(work.actions, isNot(contains(StokvelAction.closeCycle)));
    });

    test(
      'a member who has already contributed has nothing to record',
      () async {
        // Lerato in Work paid R300; Sipho in Family has a Paid contribution.
        final lerato = await _fresh(Persona.lerato)
            .read(stokvelPageProvider(SeedWorld.workId).future);
        final sipho = await _fresh(Persona.sipho)
            .read(stokvelPageProvider(SeedWorld.familyId).future);

        expect(lerato!.actions, isEmpty);
        expect(sipho!.actions, isEmpty);
      },
    );

    test('Thandi is not in Family: null, the same as a stokvel that is not '
        'there', () async {
      final container = _fresh(Persona.thandi);

      final family = await container.read(
        stokvelPageProvider(SeedWorld.familyId).future,
      );
      final missing = await container.read(
        stokvelPageProvider('no-such-stokvel').future,
      );

      expect(family, isNull);
      expect(missing, isNull);
      expect(
        stokvelPageViewStateOf(AsyncData(family)),
        isA<ViewEmpty<Object?>>(),
      );
    });
  });

  group('lifetimes', () {
    test('a page is disposed exactly once, when its last listener goes, and '
        'only that page', () async {
      final log = _DisposeLog();
      final container = ProviderContainer(
        overrides: fakeWorldAs(Persona.lerato),
        observers: [log],
      );
      addTearDown(container.dispose);

      final family = container.listen(
        stokvelPageProvider(SeedWorld.familyId),
        (_, _) {},
      );
      final work = container.listen(
        stokvelPageProvider(SeedWorld.workId),
        (_, _) {},
      );
      await container.read(stokvelPageProvider(SeedWorld.familyId).future);
      await container.read(stokvelPageProvider(SeedWorld.workId).future);
      log.lines.clear();

      family.close();
      await Future<void>.delayed(Duration.zero);

      // Names and ids only: no stokvel name, no amount, nothing a person saw.
      expect(
        log.lines.where((l) => l.contains(SeedWorld.familyId)),
        hasLength(1),
        reason: log.lines.join(', '),
      );
      expect(log.lines.where((l) => l.contains(SeedWorld.workId)), isEmpty);
      work.close();
    });

    test('the fake world is kept alive; a list is not', () async {
      final log = _DisposeLog();
      final container = ProviderContainer(
        overrides: fakeWorldAs(Persona.lerato),
        observers: [log],
      );
      addTearDown(container.dispose);

      final sub = container.listen(myStokvelsProvider, (_, _) {});
      await container.read(myStokvelsProvider.future);
      final feed = container.listen(activityFeedProvider, (_, _) {});
      await container.read(activityFeedProvider.future);
      log.lines.clear();

      sub.close();
      feed.close();
      await Future<void>.delayed(Duration.zero);

      expect(log.lines, contains('myStokvelsProvider'));
      expect(log.lines, contains('activityFeedProvider'));
      // The world is kept alive (it is overridden here, and keepAlive in the
      // app): closing a listener never disposes it.
      expect(log.lines.where((l) => l.contains('seedWorld')), isEmpty);
    });
  });
}
