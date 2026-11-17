import 'package:tallyvel/features/stokvel_detail/domain/stokvel_action.dart';

/// What to call [action] on a button.
String stokvelActionLabel(StokvelAction action) => switch (action) {
  StokvelAction.recordMyContribution => 'Record my contribution',
  StokvelAction.recordForMember => "Record a member's contribution",
  StokvelAction.closeCycle => 'Close this cycle',
  StokvelAction.payOut => 'Pay out',
  StokvelAction.openNextCycle => 'Open the next cycle',
};
