import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/contributions/presentation/contribution_status_label.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/cycles/presentation/cycle_status_label.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/memberships/presentation/role_label.dart';
import 'package:tallyvel/features/stokvel_detail/domain/stokvel_action.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_action_label.dart';

// Every contribution state a person can be in: none, or one of four statuses.
const List<ContributionStatus?> _anyMine = [
  null,
  ContributionStatus.pending,
  ContributionStatus.paid,
  ContributionStatus.confirmed,
  ContributionStatus.unknown,
];
const List<ContributionStatus?> _someMine = [
  ContributionStatus.pending,
  ContributionStatus.paid,
  ContributionStatus.confirmed,
  ContributionStatus.unknown,
];

const List<MemberRole> _treasurerOrChair = [
  MemberRole.treasurer,
  MemberRole.chairperson,
];

Set<StokvelAction> _actions(
  MemberRole role,
  CycleStatus cycle,
  ContributionStatus? mine,
) => actionsFor(role: role, cycle: cycle, mine: mine);

void main() {
  group('actionsFor: one test per rule row', () {
    test(
      '1. an unknown role may do nothing, whatever the cycle or contribution',
      () {
        for (final cycle in CycleStatus.values) {
          for (final mine in _anyMine) {
            expect(_actions(MemberRole.unknown, cycle, mine), isEmpty);
          }
        }
      },
    );

    test(
      '2. a member with no contribution in an open cycle may record theirs',
      () {
        expect(_actions(MemberRole.member, CycleStatus.open, null), {
          StokvelAction.recordMyContribution,
        });
      },
    );

    test('3. a member who already has a contribution may do nothing', () {
      for (final mine in _someMine) {
        expect(_actions(MemberRole.member, CycleStatus.open, mine), isEmpty);
      }
    });

    test('4. a member may do nothing once the cycle is not open', () {
      for (final cycle in [
        CycleStatus.closed,
        CycleStatus.paidOut,
        CycleStatus.unknown,
      ]) {
        for (final mine in _anyMine) {
          expect(_actions(MemberRole.member, cycle, mine), isEmpty);
        }
      }
    });

    test(
      '5. a treasurer or chairperson with no contribution does all four',
      () {
        for (final role in _treasurerOrChair) {
          expect(_actions(role, CycleStatus.open, null), {
            StokvelAction.recordMyContribution,
            StokvelAction.recordForMember,
            StokvelAction.closeCycle,
            StokvelAction.payOut,
          });
        }
      },
    );

    test('6. ...and without recording their own once they have one', () {
      for (final role in _treasurerOrChair) {
        for (final mine in _someMine) {
          expect(_actions(role, CycleStatus.open, mine), {
            StokvelAction.recordForMember,
            StokvelAction.closeCycle,
            StokvelAction.payOut,
          });
        }
      }
    });

    test('7. a closed cycle: pay out or open the next', () {
      for (final role in _treasurerOrChair) {
        for (final mine in _anyMine) {
          expect(_actions(role, CycleStatus.closed, mine), {
            StokvelAction.payOut,
            StokvelAction.openNextCycle,
          });
        }
      }
    });

    test('8. a paid-out cycle: only open the next', () {
      for (final role in _treasurerOrChair) {
        for (final mine in _anyMine) {
          expect(_actions(role, CycleStatus.paidOut, mine), {
            StokvelAction.openNextCycle,
          });
        }
      }
    });

    test('9. a cycle status we do not know: nothing', () {
      for (final role in _treasurerOrChair) {
        for (final mine in _anyMine) {
          expect(_actions(role, CycleStatus.unknown, mine), isEmpty);
        }
      }
    });
  });

  test('a member can never run treasurer actions, in any of the 20 states', () {
    const treasurerOnly = {
      StokvelAction.recordForMember,
      StokvelAction.closeCycle,
      StokvelAction.payOut,
      StokvelAction.openNextCycle,
    };
    for (final cycle in CycleStatus.values) {
      for (final mine in _anyMine) {
        expect(
          _actions(MemberRole.member, cycle, mine).intersection(treasurerOnly),
          isEmpty,
          reason: '$cycle / $mine',
        );
      }
    }
  });

  group('labels are words, one exhaustive switch each', () {
    test('role', () {
      expect(MemberRole.values.map(roleLabel), [
        'Member',
        'Treasurer',
        'Chairperson',
        'Member',
      ]);
    });

    test('cycle status', () {
      expect(CycleStatus.values.map(cycleStatusLabel), [
        'Open',
        'Closed',
        'Paid out',
        'Unknown',
      ]);
    });

    test('contribution status', () {
      expect(ContributionStatus.values.map(contributionStatusLabel), [
        'Pending',
        'Paid',
        'Confirmed',
        'Unknown',
      ]);
    });

    test('action', () {
      expect(StokvelAction.values.map(stokvelActionLabel), [
        'Record my contribution',
        "Record a member's contribution",
        'Close this cycle',
        'Pay out',
        'Open the next cycle',
      ]);
    });
  });
}
