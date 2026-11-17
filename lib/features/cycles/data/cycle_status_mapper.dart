import 'package:tallyvel/features/cycles/domain/cycle_status.dart';

/// Reads the API's cycle status: exactly `Open`, `Closed` or `PaidOut`.
/// Anything else is [CycleStatus.unknown].
CycleStatus cycleStatusFromApi(String? value) => switch (value) {
  'Open' => CycleStatus.open,
  'Closed' => CycleStatus.closed,
  'PaidOut' => CycleStatus.paidOut,
  _ => CycleStatus.unknown,
};
