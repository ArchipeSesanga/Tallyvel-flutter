import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/features/activity/data/activity_kind_mapper.dart';
import 'package:tallyvel/features/activity/domain/activity_kind.dart';
import 'package:tallyvel/features/contributions/data/contribution_status_mapper.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/data/cycle_status_mapper.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/memberships/data/member_role_mapper.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvels/data/contribution_frequency_mapper.dart';
import 'package:tallyvel/features/stokvels/domain/contribution_frequency.dart';

// The spellings are the ones the real API sends (README, Contract notes, 3).
void main() {
  group('every status the API sends maps to its case', () {
    test('role', () {
      expect(memberRoleFromApi('Member'), MemberRole.member);
      expect(memberRoleFromApi('Treasurer'), MemberRole.treasurer);
      expect(memberRoleFromApi('Chairperson'), MemberRole.chairperson);
    });

    test('cycle status', () {
      expect(cycleStatusFromApi('Open'), CycleStatus.open);
      expect(cycleStatusFromApi('Closed'), CycleStatus.closed);
      expect(cycleStatusFromApi('PaidOut'), CycleStatus.paidOut);
    });

    test('contribution status', () {
      expect(contributionStatusFromApi('Pending'), ContributionStatus.pending);
      expect(contributionStatusFromApi('Paid'), ContributionStatus.paid);
      expect(
        contributionStatusFromApi('Confirmed'),
        ContributionStatus.confirmed,
      );
    });

    test('frequency', () {
      expect(
        contributionFrequencyFromApi('Weekly'),
        ContributionFrequency.weekly,
      );
      expect(
        contributionFrequencyFromApi('BiWeekly'),
        ContributionFrequency.biWeekly,
      );
      expect(
        contributionFrequencyFromApi('Monthly'),
        ContributionFrequency.monthly,
      );
    });

    test('activity kind', () {
      expect(
        activityKindFromApi('ContributionRecorded'),
        ActivityKind.contributionRecorded,
      );
      expect(activityKindFromApi('PayoutMade'), ActivityKind.payoutMade);
      expect(activityKindFromApi('MemberJoined'), ActivityKind.memberJoined);
    });
  });

  group('anything else is unknown, never a crash', () {
    test('a value added to the API later', () {
      expect(memberRoleFromApi('Auditor'), MemberRole.unknown);
      expect(cycleStatusFromApi('Archived'), CycleStatus.unknown);
      expect(contributionStatusFromApi('Refunded'), ContributionStatus.unknown);
      expect(
        contributionFrequencyFromApi('Yearly'),
        ContributionFrequency.unknown,
      );
      expect(activityKindFromApi('ProofAdded'), ActivityKind.unknown);
    });

    test('a different case, because the API spelling is exact', () {
      expect(memberRoleFromApi('treasurer'), MemberRole.unknown);
      expect(cycleStatusFromApi('PAIDOUT'), CycleStatus.unknown);
      expect(cycleStatusFromApi('paidOut'), CycleStatus.unknown);
      expect(contributionStatusFromApi('paid'), ContributionStatus.unknown);
    });

    test('null, empty and padded values', () {
      expect(memberRoleFromApi(null), MemberRole.unknown);
      expect(cycleStatusFromApi(''), CycleStatus.unknown);
      expect(contributionStatusFromApi(' Paid'), ContributionStatus.unknown);
    });
  });
}
