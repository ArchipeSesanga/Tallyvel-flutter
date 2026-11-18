import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/features/activity/data/fake_activity_repository.dart';
import 'package:tallyvel/features/activity/domain/activity_kind.dart';
import 'package:tallyvel/features/contributions/data/fake_contributions_repository.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/data/fake_cycles_repository.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/home/data/fake_home_repository.dart';
import 'package:tallyvel/features/memberships/data/fake_memberships_repository.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvels/data/fake_stokvels_repository.dart';

// The numbers below are what the real API returned for the same people on a
// fresh seed (README, "Contract notes"): Lerato's home, the Family Stokvel's
// four contributions, its 100 010 collected of 200 000 due.
final _now = DateTime.utc(2026, 11, 17, 15);
final _world = SeedWorld(now: _now);

void main() {
  group('Lerato: Treasurer of Family, Member of Work', () {
    final home = FakeHomeRepository(_world, SeedWorld.leratoId);

    test("home has both cards with the API's numbers", () async {
      final cards = await home.cards();

      expect(cards.map((c) => c.name), ['Family Stokvel', 'Work Stokvel']);
      expect(cards[0].role, MemberRole.treasurer);
      expect(cards[0].paidThisCycle, Cents.zero); // her R500 is Pending
      expect(cards[0].owedThisCycle, const Cents(50000));
      expect(cards[1].role, MemberRole.member);
      expect(cards[1].paidThisCycle, const Cents(30000));
      expect(cards[1].owedThisCycle, Cents.zero);
    });

    test('the open cycle has South African dates', () async {
      final cycle = (await home.cards()).first.currentCycle!;

      expect(cycle.label, '2026-11');
      expect(cycle.status, CycleStatus.open);
      expect(cycle.startsOn, CalendarDate(2026, 11, 1));
      expect(cycle.endsOn, CalendarDate(2026, 11, 30));
    });

    test(
      'memberships say Treasurer in one stokvel and Member in the other',
      () async {
        final memberships = await FakeMembershipsRepository(
          _world,
          SeedWorld.leratoId,
        ).mine();

        expect(
          {for (final m in memberships) m.stokvelId: m.role},
          {
            SeedWorld.familyId: MemberRole.treasurer,
            SeedWorld.workId: MemberRole.member,
          },
        );
      },
    );
  });

  group('Sipho: Member of Family, Treasurer of Work', () {
    final home = FakeHomeRepository(_world, SeedWorld.siphoId);

    test("his roles are the reverse of Lerato's", () async {
      final cards = await home.cards();

      expect(
        {for (final c in cards) c.name: c.role},
        {
          'Family Stokvel': MemberRole.member,
          'Work Stokvel': MemberRole.treasurer,
        },
      );
    });

    test(
      'his boundary contribution counts: paid in Family, owes in Work',
      () async {
        final cards = await home.cards();

        expect(cards[0].paidThisCycle, const Cents(50000));
        expect(cards[0].owedThisCycle, Cents.zero);
        expect(cards[1].paidThisCycle, Cents.zero);
        expect(cards[1].owedThisCycle, const Cents(30000));
      },
    );
  });

  group('Thandi: in no stokvel', () {
    const id = SeedWorld.thandiId;

    test('home, list, memberships and activity are all empty', () async {
      expect(await FakeHomeRepository(_world, id).cards(), isEmpty);
      expect(await FakeStokvelsRepository(_world, id).mine(), isEmpty);
      expect(await FakeMembershipsRepository(_world, id).mine(), isEmpty);
      expect((await FakeActivityRepository(_world, id).page()).items, isEmpty);
    });

    test(
      'a stokvel she is not in is "not found", same as a missing id',
      () async {
        final stokvels = FakeStokvelsRepository(_world, id);

        expect(await stokvels.detail(SeedWorld.familyId), isNull);
        expect(await stokvels.detail('no-such-stokvel'), isNull);
      },
    );
  });

  group('Family Stokvel as the API returns it', () {
    const lerato = SeedWorld.leratoId;

    test('detail: 4 members, R1 000,10 collected of R2 000,00 due', () async {
      final detail = await FakeStokvelsRepository(
        _world,
        lerato,
      ).detail(SeedWorld.familyId);

      expect(detail!.memberCount, 4);
      expect(detail.contributionAmount, const Cents(50000));
      expect(detail.currentCycle!.collected, const Cents(100010));
      expect(detail.currentCycle!.due, const Cents(200000));
      expect(detail.currentCycle!.endsOn, CalendarDate(2026, 11, 30));
      expect(detail.members.every((m) => m.fullName != null), isTrue);
    });

    test(
      'contributions: all three statuses, an exact 10 cents, oldest first',
      () async {
        final page = await FakeContributionsRepository(
          _world,
          lerato,
        ).page(SeedWorld.familyId);

        expect(page.items, hasLength(4));
        expect(page.hasMore, isFalse);
        expect(page.items.map((c) => c.status).toSet(), {
          ContributionStatus.pending,
          ContributionStatus.paid,
          ContributionStatus.confirmed,
        });
        expect(page.items.any((c) => c.amount == const Cents(10)), isTrue);
        final times = page.items.map((c) => c.recordedAt).toList();
        expect(times, [...times]..sort());
      },
    );

    test(
      'the boundary contribution is October in UTC, November in Johannesburg',
      () async {
        final first = (await FakeContributionsRepository(
          _world,
          lerato,
        ).page(SeedWorld.familyId)).items.first;

        expect(first.recordedAt, DateTime.utc(2026, 10, 31, 22, 30));
        expect(first.recordedAt.isUtc, isTrue);
        expect(CalendarDate.inSouthAfrica(first.recordedAt).month, 11);
        expect(first.cycleLabel, '2026-11');
      },
    );

    test('paging: a token on every page but the last', () async {
      final repo = FakeContributionsRepository(_world, lerato);

      final first = await repo.page(SeedWorld.familyId, pageSize: 3);
      expect(first.items, hasLength(3));
      expect(first.hasMore, isTrue);

      final second = await repo.page(
        SeedWorld.familyId,
        pageSize: 3,
        pageToken: first.nextPageToken,
      );
      expect(second.items, hasLength(1));
      expect(second.hasMore, isFalse);
      expect(second.nextPageToken, isNull);
    });

    test('contributions of a stokvel she is not in are empty', () async {
      final page = await FakeContributionsRepository(
        _world,
        SeedWorld.thandiId,
      ).page(SeedWorld.familyId);

      expect(page.items, isEmpty);
    });

    test('cycles: the one open cycle', () async {
      final cycles = await FakeCyclesRepository(
        _world,
        lerato,
      ).forStokvel(SeedWorld.familyId);

      expect(cycles, hasLength(1));
      expect(cycles.single.status, CycleStatus.open);
      expect(
        await FakeCyclesRepository(
          _world,
          SeedWorld.thandiId,
        ).forStokvel(SeedWorld.familyId),
        isEmpty,
      );
    });
  });

  group('activity', () {
    test("is newest first and only from the person's own stokvels", () async {
      final page = await FakeActivityRepository(
        _world,
        SeedWorld.siphoId,
      ).page(pageSize: 100);

      final times = page.items.map((i) => i.occurredAt).toList();
      expect(times, [...times]..sort((a, b) => b.compareTo(a)));
      expect(page.items.map((i) => i.kind).toSet(), {
        ActivityKind.contributionRecorded,
        ActivityKind.memberJoined,
      });
      expect(
        page.items
            .where((i) => i.kind == ActivityKind.memberJoined)
            .every((i) => i.amount == null),
        isTrue,
      );
    });
  });

  group('the seed in another month', () {
    test(
      'December has its own cycle and still four Family contributions',
      () async {
        final december = SeedWorld(now: DateTime.utc(2026, 12, 10, 8));
        final page = await FakeContributionsRepository(
          december,
          SeedWorld.leratoId,
        ).page(SeedWorld.familyId);

        expect(page.items, hasLength(4));
        expect(page.items.every((c) => c.cycleLabel == '2026-12'), isTrue);
        expect(page.items.any((c) => c.amount == const Cents(10)), isTrue);
        final card = (await FakeHomeRepository(
          december,
          SeedWorld.leratoId,
        ).cards()).first;
        expect(card.currentCycle!.endsOn, CalendarDate(2026, 12, 31));
      },
    );
  });
}
