import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';
import 'package:tallyvel/features/cycles/domain/cycle.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvel_detail/domain/stokvel_action.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

part 'stokvel_page.freezed.dart';

/// Everything one stokvel's page shows, for the signed-in person.
@freezed
abstract class StokvelPage with _$StokvelPage {
  /// Creates a stokvel page.
  const factory StokvelPage({
    required StokvelDetail detail,
    required List<Cycle> cycles,
    required PageOf<Contribution> contributions,

    /// What the person is in THIS stokvel (from their membership).
    required MemberRole role,

    /// The status of the person's own contribution in the cycle shown, or
    /// `null` if they have none.
    ContributionStatus? myContribution,
  }) = _StokvelPage;

  const StokvelPage._();

  /// The cycle the actions are about: the open one, otherwise the latest. If
  /// there is no cycle at all, nothing is running, which for the actions is
  /// the same as a cycle that has been paid out.
  CycleStatus get cycleStatus =>
      detail.currentCycle?.status ??
      (cycles.isEmpty ? CycleStatus.paidOut : cycles.last.status);

  /// What the person can do here. See [actionsFor].
  Set<StokvelAction> get actions =>
      actionsFor(role: role, cycle: cycleStatus, mine: myContribution);
}
