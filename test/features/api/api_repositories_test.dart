import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/network/api_client.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/features/contributions/data/api_contributions_repository.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/data/api_cycles_repository.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/home/data/api_home_repository.dart';
import 'package:tallyvel/features/memberships/data/api_memberships_repository.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvels/data/api_stokvels_repository.dart';
import 'package:tallyvel/features/stokvels/domain/contribution_frequency.dart';

import '../../support/fake_http_adapter.dart';

const Map<String, Object?> _homeBody = {
  'stokvels': [
    {
      'stokvelId': 'g-1',
      'name': 'Family Stokvel',
      'role': 'Treasurer',
      'currentCycle': {
        'id': 'c-1',
        'label': '2026-11',
        'status': 'Open',
        'startsOn': '2026-11-01',
        'endsOn': '2026-11-30',
      },
      'paidThisCycleCents': 50000,
      'owedThisCycleCents': 0,
      'nextPayoutDate': '2026-11-30',
    },
    {
      'stokvelId': 'g-2',
      'name': 'Work Stokvel',
      'role': 'Somebody New',
      'currentCycle': null,
      'paidThisCycleCents': 0,
      'owedThisCycleCents': 0,
      'nextPayoutDate': null,
    },
  ],
};

const Map<String, Object?> _stokvelBody = {
  'id': 'g-1',
  'name': 'Family Stokvel',
  'contributionAmountCents': 50000,
  'cycle': 'Monthly',
  'createdAt': '2026-01-05T08:00:00Z',
  'memberCount': 2,
  'rules': null,
  'members': [
    {
      'userId': 'u-1',
      'role': 'Treasurer',
      'joinedAt': '2026-01-05T08:00:00Z',
      'fullName': 'Lerato M.',
    },
    {'userId': 'u-2', 'role': 'Member', 'joinedAt': '2026-02-01T08:00:00Z'},
  ],
  'currentCycle': {
    'id': 'c-1',
    'label': '2026-11',
    'status': 'Open',
    'endsOn': '2026-11-30',
    'collectedCents': 50000,
    'dueCents': 100000,
  },
};

FakeHttpAdapter _answering(Map<String, FakeReply> byPath) =>
    FakeHttpAdapter((o) => byPath[o.uri.path] ?? const FakeReply(404));

TokenStore _tokens() => TokenStore();

Dio _dio(FakeHttpAdapter adapter) => createApiDio(
  baseUrl: 'http://api.test',
  tokens: _tokens(),
  adapter: adapter,
);

void main() {
  test('home: cards with money in cents, dates, and an unknown role', () async {
    final adapter = _answering({
      '/api/v1/me/home': const FakeReply(200, body: _homeBody),
    });

    final cards = await ApiHomeRepository(_dio(adapter)).cards();

    expect(cards, hasLength(2));
    expect(cards[0].name, 'Family Stokvel');
    expect(cards[0].role, MemberRole.treasurer);
    expect(cards[0].paidThisCycle, const Cents(50000));
    expect(cards[0].currentCycle?.status, CycleStatus.open);
    expect(cards[0].currentCycle?.endsOn, CalendarDate.parse('2026-11-30'));
    expect(cards[0].nextPayoutDate, CalendarDate.parse('2026-11-30'));
    expect(cards[1].role, MemberRole.unknown);
    expect(cards[1].currentCycle, isNull);
    expect(cards[1].nextPayoutDate, isNull);
  });

  test('home: a body that is not the contract is Unexpected', () async {
    final adapter = _answering({
      '/api/v1/me/home': const FakeReply(200, body: {'stokvels': 'nope'}),
    });

    await expectLater(
      ApiHomeRepository(_dio(adapter)).cards(),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('home: a 500 is a ServerFailure with its correlation id', () async {
    final adapter = _answering({
      '/api/v1/me/home': const FakeReply(
        500,
        body: {'correlationId': 'abc123', 'detail': 'private'},
      ),
    });

    await expectLater(
      ApiHomeRepository(_dio(adapter)).cards(),
      throwsA(
        isA<ServerFailure>().having(
          (f) => f.correlationId,
          'correlationId',
          'abc123',
        ),
      ),
    );
  });

  test(
    'stokvel: detail maps members, the open cycle and the frequency',
    () async {
      final adapter = _answering({
        '/api/v1/stokvels/g-1': const FakeReply(200, body: _stokvelBody),
      });

      final detail = await ApiStokvelsRepository(_dio(adapter)).detail('g-1');

      expect(detail!.frequency, ContributionFrequency.monthly);
      expect(detail.members.map((m) => m.role), [
        MemberRole.treasurer,
        MemberRole.member,
      ]);
      expect(detail.members[1].fullName, isNull);
      expect(detail.currentCycle?.collected, const Cents(50000));
      expect(detail.currentCycle?.due, const Cents(100000));
      expect(detail.rules, isNull);
    },
  );

  test(
    'stokvel: a 404 is null, the same for missing and not a member',
    () async {
      final adapter = _answering({});

      expect(await ApiStokvelsRepository(_dio(adapter)).detail('nope'), isNull);
    },
  );

  test('stokvel: the list counts the members', () async {
    final adapter = _answering({
      '/api/v1/stokvels': const FakeReply(200, body: [_stokvelBody]),
    });

    final list = await ApiStokvelsRepository(_dio(adapter)).mine();

    expect(list.single.memberCount, 2);
    expect(list.single.contributionAmount, const Cents(50000));
  });

  test('cycles: an unknown status is unknown, not a crash', () async {
    final adapter = _answering({
      '/api/v1/stokvels/g-1/cycles': const FakeReply(
        200,
        body: [
          {
            'id': 'c-1',
            'stokvelId': 'g-1',
            'label': '2026-11',
            'status': 'Open',
          },
          {
            'id': 'c-0',
            'stokvelId': 'g-1',
            'label': '2026-10',
            'status': 'Frozen',
          },
        ],
      ),
    });

    final cycles = await ApiCyclesRepository(_dio(adapter)).forStokvel('g-1');

    expect(cycles.map((c) => c.status), [
      CycleStatus.open,
      CycleStatus.unknown,
    ]);
  });

  group('contributions', () {
    const item = {
      'id': 'k-1',
      'stokvelId': 'g-1',
      'memberUserId': 'u-1',
      'cycle': '2026-11',
      'amountCents': 50000,
      'status': 'Confirmed',
      'recordedAt': '2026-11-03T10:00:00Z',
    };

    test('a page with a token has more; the empty token ends it', () async {
      final adapter = FakeHttpAdapter(
        (o) => FakeReply(
          200,
          body: {
            'items': [item],
            'nextPageToken': o.queryParameters['pageToken'] == null
                ? 'opaque-token'
                : '',
          },
        ),
      );
      final repo = ApiContributionsRepository(_dio(adapter));

      final first = await repo.page('g-1', pageSize: 1);
      final last = await repo.page('g-1', pageToken: first.nextPageToken);

      expect(first.hasMore, isTrue);
      expect(first.items.single.status, ContributionStatus.confirmed);
      expect(first.items.single.hasProof, isFalse);
      expect(last.hasMore, isFalse);
      expect(
        adapter.requests.last.queryParameters['pageToken'],
        'opaque-token',
      );
    });
  });

  test('memberships: the role per stokvel comes from the home cards', () async {
    final adapter = _answering({
      '/api/v1/me/home': const FakeReply(200, body: _homeBody),
    });

    final memberships = await ApiMembershipsRepository(_dio(adapter)).mine();

    expect(memberships.map((m) => (m.stokvelId, m.role)), [
      ('g-1', MemberRole.treasurer),
      ('g-2', MemberRole.unknown),
    ]);
  });

  group('a 401 on a data request', () {
    test('forgets the token and tells the app', () async {
      var told = 0;
      final tokens = TokenStore()..accessToken = 'old';
      final dio = createApiDio(
        baseUrl: 'http://api.test',
        tokens: tokens,
        adapter: _answering({'/api/v1/me/home': const FakeReply(401)}),
        onUnauthorised: () => told++,
      );

      await expectLater(
        ApiHomeRepository(dio).cards(),
        throwsA(isA<UnauthorisedFailure>()),
      );

      expect(tokens.accessToken, isNull);
      expect(told, 1);
    });

    test('is not "the token ended" when it is the sign-in itself', () async {
      var told = 0;
      final dio = createApiDio(
        baseUrl: 'http://api.test',
        tokens: TokenStore(),
        adapter: _answering({'/api/v1/auth/login': const FakeReply(401)}),
        onUnauthorised: () => told++,
      );

      await expectLater(
        dio.post<Object?>('/api/v1/auth/login'),
        throwsA(anything),
      );

      expect(told, 0);
    });
  });
}
