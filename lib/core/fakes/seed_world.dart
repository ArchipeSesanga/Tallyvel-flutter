import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';
import 'package:tallyvel/features/activity/domain/activity_kind.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/domain/cycle.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/memberships/domain/membership.dart';
import 'package:tallyvel/features/stokvels/domain/contribution_frequency.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

/// A person in the seed.
class SeedUser {
  /// Creates a user.
  const SeedUser(this.id, this.fullName);

  /// The user's id.
  final String id;

  /// The user's full name.
  final String fullName;
}

/// A membership row: who is in a stokvel, as what.
class SeedMember {
  /// Creates a member row.
  const SeedMember(this.userId, this.role);

  /// The member's user id.
  final String userId;

  /// The member's role in this stokvel.
  final MemberRole role;
}

/// A stokvel with its members and its one open cycle.
class SeedStokvel {
  /// Creates a seed stokvel.
  const SeedStokvel({
    required this.id,
    required this.name,
    required this.amount,
    required this.rules,
    required this.members,
    required this.cycle,
    required this.startsOn,
    required this.endsOn,
  });

  /// The stokvel's id.
  final String id;

  /// The stokvel's name.
  final String name;

  /// The contribution amount for one cycle.
  final Cents amount;

  /// The rules a person agrees to when they join.
  final String rules;

  /// Who is in it.
  final List<SeedMember> members;

  /// Its open cycle.
  final Cycle cycle;

  /// The first day of the open cycle.
  final CalendarDate startsOn;

  /// The last day of the open cycle (the due date).
  final CalendarDate endsOn;
}

/// The same people, stokvels and contributions that the real API seeds in
/// Development, so a screen that works on the fakes shows what the API will
/// send.
///
/// | Person | Family Stokvel (R500) | Work Stokvel (R300) |
/// |---|---|---|
/// | Lerato | Treasurer | Member |
/// | Sipho | Member | Treasurer |
/// | Thandi | not in it | not in it |
///
/// The source is `Infrastructure/Persistence/SeedData.cs` and
/// `DemoAdditions.cs` in the API repo. The one deliberate difference: the
/// API works out `nextPayoutDate` from the stokvel's creation date; here it is
/// the cycle's last day, because nothing in the app depends on the exact day.
class SeedWorld {
  /// Builds the seed as it would look at [now] (an instant in UTC).
  factory SeedWorld({required DateTime now}) {
    final utcNow = now.toUtc();
    final today = CalendarDate.inSouthAfrica(utcNow);
    final startsOn = CalendarDate(today.year, today.month, 1);
    final endsOn = CalendarDate(
      today.year,
      today.month,
      DateTime.utc(today.year, today.month + 1, 0).day,
    );
    final label =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}';
    // Midnight in South Africa is 22:00 UTC the evening before.
    final cycleStart = DateTime.utc(
      startsOn.year,
      startsOn.month,
      startsOn.day,
    ).subtract(const Duration(hours: 2));

    const users = [
      SeedUser(leratoId, 'Lerato Mokoena'),
      SeedUser(thaboId, 'Thabo Nkosi'),
      SeedUser(lindiweId, 'Lindiwe Dube'),
      SeedUser(siphoId, 'Sipho Zulu'),
      SeedUser(nomsaId, 'Nomsa Khumalo'),
      SeedUser(nandiId, 'Nandi Mthembu'),
      SeedUser(thandiId, 'Thandi Ndlovu'),
    ];

    SeedStokvel stokvel(
      String id,
      String name,
      int cents,
      String rules,
      List<SeedMember> members,
    ) => SeedStokvel(
      id: id,
      name: name,
      amount: Cents(cents),
      rules: rules,
      members: members,
      cycle: Cycle(
        id: 'cycle-$id-$label',
        stokvelId: id,
        label: label,
        status: CycleStatus.open,
      ),
      startsOn: startsOn,
      endsOn: endsOn,
    );

    final family = stokvel(
      familyId,
      'Family Stokvel',
      50000,
      'Contributions are due by the 5th of every month. A late payment is '
          'made up with the next one. Decisions about payouts are made '
          'together at the monthly meeting.',
      const [
        SeedMember(thaboId, MemberRole.chairperson),
        SeedMember(leratoId, MemberRole.treasurer),
        SeedMember(lindiweId, MemberRole.member),
        SeedMember(siphoId, MemberRole.member),
      ],
    );
    final work = stokvel(
      workId,
      'Work Stokvel',
      30000,
      'Everyone pays R300 a month on pay day. Payouts rotate in the order '
          'agreed at the start of the year. Leaving early means waiting until '
          'the end of the rotation for any refund.',
      const [
        SeedMember(nomsaId, MemberRole.chairperson),
        SeedMember(leratoId, MemberRole.member),
        SeedMember(nandiId, MemberRole.member),
        SeedMember(siphoId, MemberRole.treasurer),
      ],
    );

    var next = 0;
    Contribution contribution(
      SeedStokvel s,
      String memberId,
      int cents,
      ContributionStatus status,
      DateTime recordedAt,
    ) => Contribution(
      id: 'contribution-${next++}',
      stokvelId: s.id,
      memberUserId: memberId,
      cycleLabel: s.cycle.label,
      amount: Cents(cents),
      status: status,
      recordedAt: recordedAt,
      hasProof: false,
      canDownloadProof: false,
    );

    // Recorded "hours" before now, but never before the cycle began.
    DateTime ago(int hours) {
      final at = utcNow.subtract(Duration(hours: hours));
      return at.isBefore(cycleStart) ? cycleStart : at;
    }

    // The boundary contribution belongs to the November 2026 cycle: 22:30 UTC
    // on 31 October is already 1 November in South Africa.
    final midnightAt = DateTime.utc(2026, 10, 31, 22, 30);
    final currentIsNovember = label == '2026-11';

    // Oldest first, the API's default order.
    final contributions = <Contribution>[
      if (currentIsNovember)
        contribution(
          family,
          siphoId,
          50000,
          ContributionStatus.paid,
          midnightAt,
        ),
      contribution(
        family,
        thaboId,
        50000,
        ContributionStatus.confirmed,
        ago(72),
      ),
      contribution(
        family,
        lindiweId,
        currentIsNovember ? 10 : 50000,
        ContributionStatus.paid,
        ago(48),
      ),
      contribution(
        family,
        leratoId,
        50000,
        ContributionStatus.pending,
        ago(24),
      ),
      if (!currentIsNovember)
        contribution(family, siphoId, 10, ContributionStatus.paid, ago(12)),
      contribution(work, nomsaId, 30000, ContributionStatus.confirmed, ago(60)),
      contribution(work, leratoId, 30000, ContributionStatus.paid, ago(36)),
    ];

    return SeedWorld._(
      now: utcNow,
      users: users,
      stokvels: [family, work],
      contributions: contributions,
    );
  }

  const SeedWorld._({
    required this.now,
    required this.users,
    required this.stokvels,
    required this.contributions,
  });

  /// Lerato Mokoena: Treasurer of Family, Member of Work.
  static const leratoId = 'user-lerato';

  /// Sipho Zulu: Member of Family, Treasurer of Work.
  static const siphoId = 'user-sipho';

  /// Thandi Ndlovu: in no stokvel.
  static const thandiId = 'user-thandi';

  /// Thabo Nkosi, Chairperson of Family.
  static const thaboId = 'user-thabo';

  /// Lindiwe Dube, Member of Family.
  static const lindiweId = 'user-lindiwe';

  /// Nomsa Khumalo, Chairperson of Work.
  static const nomsaId = 'user-nomsa';

  /// Nandi Mthembu, Member of Work.
  static const nandiId = 'user-nandi';

  /// The Family Stokvel's id.
  static const familyId = 'stokvel-family';

  /// The Work Stokvel's id.
  static const workId = 'stokvel-work';

  /// The instant the seed was built for (UTC).
  final DateTime now;

  /// Everyone.
  final List<SeedUser> users;

  /// Both stokvels.
  final List<SeedStokvel> stokvels;

  /// Every contribution, oldest first.
  final List<Contribution> contributions;

  /// The name of [userId].
  String nameOf(String userId) =>
      users.firstWhere((u) => u.id == userId).fullName;

  /// The stokvels [userId] belongs to, in seed order.
  List<SeedStokvel> stokvelsOf(String userId) => [
    for (final s in stokvels)
      if (s.members.any((m) => m.userId == userId)) s,
  ];

  /// [userId]'s role in [stokvel], or `null` if they are not in it.
  MemberRole? roleIn(SeedStokvel stokvel, String userId) {
    for (final m in stokvel.members) {
      if (m.userId == userId) return m.role;
    }
    return null;
  }

  /// [userId]'s place in each stokvel they belong to.
  List<Membership> membershipsOf(String userId) => [
    for (final s in stokvelsOf(userId))
      Membership(stokvelId: s.id, role: roleIn(s, userId)!),
  ];

  /// The stokvel with [id] if [userId] is in it, otherwise `null` (the same
  /// answer as "no such stokvel").
  SeedStokvel? visibleTo(String userId, String id) {
    for (final s in stokvelsOf(userId)) {
      if (s.id == id) return s;
    }
    return null;
  }

  Iterable<Contribution> _inCycle(SeedStokvel stokvel) => contributions.where(
    (c) => c.stokvelId == stokvel.id && c.cycleLabel == stokvel.cycle.label,
  );

  /// What the whole stokvel has collected this cycle (Paid and Confirmed).
  Cents collected(SeedStokvel stokvel) =>
      _inCycle(stokvel)
          .where((c) => c.status.countsTowardsTotal)
          .fold(Cents.zero, (sum, c) => sum + c.amount);

  /// The home screen's card for [userId] in [stokvel].
  HomeCard cardFor(String userId, SeedStokvel stokvel) {
    final paid = _inCycle(stokvel)
        .where((c) => c.memberUserId == userId && c.status.countsTowardsTotal)
        .fold(Cents.zero, (sum, c) => sum + c.amount);
    final owed = stokvel.amount - paid;
    return HomeCard(
      stokvelId: stokvel.id,
      name: stokvel.name,
      role: roleIn(stokvel, userId)!,
      paidThisCycle: paid,
      owedThisCycle: owed.isNegative ? Cents.zero : owed,
      currentCycle: HomeCycle(
        id: stokvel.cycle.id,
        label: stokvel.cycle.label,
        status: stokvel.cycle.status,
        startsOn: stokvel.startsOn,
        endsOn: stokvel.endsOn,
      ),
      nextPayoutDate: stokvel.endsOn,
    );
  }

  /// [stokvel] as it appears in a list.
  Stokvel summary(SeedStokvel stokvel) => Stokvel(
    id: stokvel.id,
    name: stokvel.name,
    contributionAmount: stokvel.amount,
    frequency: ContributionFrequency.monthly,
    createdAt: now,
    memberCount: stokvel.members.length,
  );

  /// [stokvel] as its page shows it.
  StokvelDetail detail(SeedStokvel stokvel) => StokvelDetail(
    id: stokvel.id,
    name: stokvel.name,
    contributionAmount: stokvel.amount,
    frequency: ContributionFrequency.monthly,
    createdAt: now,
    members: [
      for (final m in stokvel.members)
        StokvelMember(
          userId: m.userId,
          role: m.role,
          joinedAt: now,
          fullName: nameOf(m.userId),
        ),
    ],
    memberCount: stokvel.members.length,
    currentCycle: CycleProgress(
      id: stokvel.cycle.id,
      label: stokvel.cycle.label,
      status: stokvel.cycle.status,
      collected: collected(stokvel),
      due: stokvel.amount * stokvel.members.length,
      endsOn: stokvel.endsOn,
    ),
    rules: stokvel.rules,
  );

  /// The activity feed for [userId], newest first: a line for every
  /// contribution and every member of the stokvels they are in.
  List<ActivityItem> activityOf(String userId) {
    final items = <ActivityItem>[];
    for (final s in stokvelsOf(userId)) {
      for (final c in contributions.where((c) => c.stokvelId == s.id)) {
        items.add(
          ActivityItem(
            id: 'c:${c.id}',
            kind: ActivityKind.contributionRecorded,
            stokvelId: s.id,
            stokvelName: s.name,
            occurredAt: c.recordedAt,
            amount: c.amount,
            personName: nameOf(c.memberUserId),
          ),
        );
      }
      for (final m in s.members) {
        items.add(
          ActivityItem(
            id: 'm:${s.id}:${m.userId}',
            kind: ActivityKind.memberJoined,
            stokvelId: s.id,
            stokvelName: s.name,
            occurredAt: now.subtract(const Duration(days: 7)),
            personName: nameOf(m.userId),
          ),
        );
      }
    }
    return items..sort((a, b) {
      final byTime = b.occurredAt.compareTo(a.occurredAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  }
}
