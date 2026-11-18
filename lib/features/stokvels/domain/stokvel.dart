import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvels/domain/contribution_frequency.dart';

part 'stokvel.freezed.dart';

/// A stokvel as it appears in the person's list.
@freezed
abstract class Stokvel with _$Stokvel {
  /// Creates a stokvel.
  const factory Stokvel({
    required String id,
    required String name,
    required Cents contributionAmount,
    required ContributionFrequency frequency,

    /// An instant, in UTC.
    required DateTime createdAt,
    required int memberCount,
  }) = _Stokvel;
}

/// One member of a stokvel, as the detail page lists them.
@freezed
abstract class StokvelMember with _$StokvelMember {
  /// Creates a member.
  const factory StokvelMember({
    required String userId,
    required MemberRole role,

    /// An instant, in UTC.
    required DateTime joinedAt,

    /// `null` when the API does not send names for this response.
    String? fullName,
  }) = _StokvelMember;
}

/// The open cycle as the stokvel's page shows it.
@freezed
abstract class CycleProgress with _$CycleProgress {
  /// Creates the progress of an open cycle.
  const factory CycleProgress({
    required String id,
    required String label,
    required CycleStatus status,

    /// What has arrived (Paid and Confirmed contributions).
    required Cents collected,

    /// What the whole stokvel owes for the cycle.
    required Cents due,

    /// The due date, a South African calendar day. `null` only for a cycle
    /// created before cycles had dates.
    CalendarDate? endsOn,
  }) = _CycleProgress;
}

/// One stokvel with everything its page shows.
@freezed
abstract class StokvelDetail with _$StokvelDetail {
  /// Creates a stokvel detail.
  const factory StokvelDetail({
    required String id,
    required String name,
    required Cents contributionAmount,
    required ContributionFrequency frequency,

    /// An instant, in UTC.
    required DateTime createdAt,
    required List<StokvelMember> members,
    required int memberCount,

    /// `null` when no cycle is open.
    CycleProgress? currentCycle,

    /// What a person agrees to when they join. `null` if none was set.
    String? rules,
  }) = _StokvelDetail;
}
