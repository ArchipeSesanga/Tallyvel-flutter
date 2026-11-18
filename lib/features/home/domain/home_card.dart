import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/core/time/calendar_date.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';

part 'home_card.freezed.dart';

/// The open cycle on a home card.
@freezed
abstract class HomeCycle with _$HomeCycle {
  /// Creates a home cycle.
  const factory HomeCycle({
    required String id,
    required String label,
    required CycleStatus status,

    /// South African calendar days. `null` only for a cycle created before
    /// cycles had dates.
    CalendarDate? startsOn,

    /// The due date.
    CalendarDate? endsOn,
  }) = _HomeCycle;
}

/// One stokvel on the home screen, with only the signed-in person's own
/// numbers.
@freezed
abstract class HomeCard with _$HomeCard {
  /// Creates a home card.
  const factory HomeCard({
    required String stokvelId,
    required String name,

    /// What the person is in *this* stokvel. Decides which buttons show.
    required MemberRole role,
    required Cents paidThisCycle,
    required Cents owedThisCycle,

    /// `null` when no cycle is open.
    HomeCycle? currentCycle,

    /// `null` when there is no open cycle.
    CalendarDate? nextPayoutDate,
  }) = _HomeCard;
}
