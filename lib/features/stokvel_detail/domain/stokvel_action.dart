import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';

/// Something a person can do on a stokvel's page.
enum StokvelAction {
  /// Record the person's own contribution for the open cycle.
  recordMyContribution,

  /// Record another member's contribution (treasurer only).
  recordForMember,

  /// Close the open cycle (treasurer only).
  closeCycle,

  /// Pay a cycle out to a member (treasurer only).
  payOut,

  /// Open the next cycle (treasurer only).
  openNextCycle,
}

/// "What can I do here?", answered in one place and in one exhaustive match.
///
/// The three inputs are the person's [role] in THIS stokvel, the [cycle]'s
/// status, and [mine]: the status of the person's own contribution in that
/// cycle, or `null` if they have none. The match has no wildcard over a
/// status, so adding a status to any of the three enums stops this file from
/// compiling until every row says what it means.
///
/// The rows come from the API's rules, not from guesses (`T/C` is treasurer or
/// chairperson):
///
/// 1. Unknown role, any cycle, any contribution: nothing. A role we do not
///    know gets no power.
/// 2. Member, open cycle, no contribution: record my contribution.
/// 3. Member, open cycle, a contribution in any status: nothing. The API
///    refuses a second contribution from one member for one cycle (409).
/// 4. Member, cycle closed, paid out or unknown: nothing. Only a treasurer or
///    chairperson acts on a cycle.
/// 5. T/C, open cycle, no contribution: record mine and anyone's, close, pay
///    out.
/// 6. T/C, open cycle, a contribution: record anyone's, close, pay out.
/// 7. T/C, closed cycle: pay out, open the next cycle.
/// 8. T/C, paid-out cycle: open the next cycle.
/// 9. T/C, unknown cycle status: nothing.
///
/// Two of these are choices the API does not force: it records a contribution
/// whatever the cycle's status, and it accepts a payout on an open cycle (a
/// payout is independent of closing). The app offers recording only while the
/// cycle is open and a payout only until it has been paid out.
Set<StokvelAction> actionsFor({
  required MemberRole role,
  required CycleStatus cycle,
  required ContributionStatus? mine,
}) => switch ((role, cycle, mine)) {
  // 1
  (
    MemberRole.unknown,
    CycleStatus.open ||
        CycleStatus.closed ||
        CycleStatus.paidOut ||
        CycleStatus.unknown,
    null ||
        ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {},
  // 2
  (MemberRole.member, CycleStatus.open, null) => const {
    StokvelAction.recordMyContribution,
  },
  // 3
  (
    MemberRole.member,
    CycleStatus.open,
    ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {},
  // 4
  (
    MemberRole.member,
    CycleStatus.closed || CycleStatus.paidOut || CycleStatus.unknown,
    null ||
        ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {},
  // 5
  (MemberRole.treasurer || MemberRole.chairperson, CycleStatus.open, null) =>
    const {
      StokvelAction.recordMyContribution,
      StokvelAction.recordForMember,
      StokvelAction.closeCycle,
      StokvelAction.payOut,
    },
  // 6
  (
    MemberRole.treasurer || MemberRole.chairperson,
    CycleStatus.open,
    ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {
      StokvelAction.recordForMember,
      StokvelAction.closeCycle,
      StokvelAction.payOut,
    },
  // 7
  (
    MemberRole.treasurer || MemberRole.chairperson,
    CycleStatus.closed,
    null ||
        ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {StokvelAction.payOut, StokvelAction.openNextCycle},
  // 8
  (
    MemberRole.treasurer || MemberRole.chairperson,
    CycleStatus.paidOut,
    null ||
        ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {StokvelAction.openNextCycle},
  // 9
  (
    MemberRole.treasurer || MemberRole.chairperson,
    CycleStatus.unknown,
    null ||
        ContributionStatus.pending ||
        ContributionStatus.paid ||
        ContributionStatus.confirmed ||
        ContributionStatus.unknown,
  ) =>
    const {},
};
