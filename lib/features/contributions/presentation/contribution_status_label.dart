import 'package:tallyvel/features/contributions/domain/contribution_status.dart';

/// What to call [status] on screen.
String contributionStatusLabel(ContributionStatus status) => switch (status) {
  ContributionStatus.pending => 'Pending',
  ContributionStatus.paid => 'Paid',
  ContributionStatus.confirmed => 'Confirmed',
  ContributionStatus.unknown => 'Unknown',
};
