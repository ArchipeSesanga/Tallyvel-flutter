import 'package:tallyvel/features/cycles/domain/cycle_status.dart';

/// What to call [status] on screen.
String cycleStatusLabel(CycleStatus status) => switch (status) {
  CycleStatus.open => 'Open',
  CycleStatus.closed => 'Closed',
  CycleStatus.paidOut => 'Paid out',
  CycleStatus.unknown => 'Unknown',
};
