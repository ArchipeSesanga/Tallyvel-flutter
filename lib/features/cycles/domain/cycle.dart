import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/features/cycles/domain/cycle_status.dart';

part 'cycle.freezed.dart';

/// One collection period of one stokvel. The API's cycle list carries no dates;
/// the open cycle's due date comes with the stokvel and the home screen.
@freezed
abstract class Cycle with _$Cycle {
  /// Creates a cycle.
  const factory Cycle({
    required String id,
    required String stokvelId,

    /// For example `2026-11`. Contributions name their cycle by this label.
    required String label,
    required CycleStatus status,
  }) = _Cycle;
}
