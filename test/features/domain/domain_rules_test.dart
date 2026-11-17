import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/memberships/domain/membership.dart';

void main() {
  group('MemberRole', () {
    test(
      'Treasurer and Chairperson may run treasurer actions, nobody else',
      () {
        expect(MemberRole.treasurer.canRunTreasurerActions, isTrue);
        expect(MemberRole.chairperson.canRunTreasurerActions, isTrue);
        expect(MemberRole.member.canRunTreasurerActions, isFalse);
        // A role we do not know gets no power, rather than all of it.
        expect(MemberRole.unknown.canRunTreasurerActions, isFalse);
      },
    );
  });

  group('ContributionStatus', () {
    test('only Paid and Confirmed count towards a total', () {
      expect(ContributionStatus.paid.countsTowardsTotal, isTrue);
      expect(ContributionStatus.confirmed.countsTowardsTotal, isTrue);
      expect(ContributionStatus.pending.countsTowardsTotal, isFalse);
      expect(ContributionStatus.unknown.countsTowardsTotal, isFalse);
    });
  });

  group('PageOf', () {
    test('a page with no token is the last page', () {
      const last = PageOf<int>(items: [1, 2]);
      expect(last.hasMore, isFalse);
    });

    test('a page with a token has more', () {
      const first = PageOf<int>(items: [1, 2], nextPageToken: 'abc');
      expect(first.hasMore, isTrue);
    });

    test('compares by value', () {
      expect(
        const PageOf<int>(items: [1], nextPageToken: 'a'),
        const PageOf<int>(items: [1], nextPageToken: 'a'),
      );
    });
  });

  group('Membership', () {
    test('compares by value', () {
      expect(
        const Membership(stokvelId: 'f', role: MemberRole.treasurer),
        const Membership(stokvelId: 'f', role: MemberRole.treasurer),
      );
      expect(
        const Membership(stokvelId: 'f', role: MemberRole.treasurer),
        isNot(const Membership(stokvelId: 'f', role: MemberRole.member)),
      );
    });

    test('the same person holds different roles in different stokvels', () {
      const family = Membership(
        stokvelId: 'family',
        role: MemberRole.treasurer,
      );
      const work = Membership(stokvelId: 'work', role: MemberRole.member);
      expect(family.role.canRunTreasurerActions, isTrue);
      expect(work.role.canRunTreasurerActions, isFalse);
    });
  });
}
