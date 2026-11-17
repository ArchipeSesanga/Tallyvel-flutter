import 'package:tallyvel/features/contributions/domain/contribution_status.dart';

/// Reads the API's contribution status: exactly `Pending`, `Paid` or
/// `Confirmed`. Anything else is [ContributionStatus.unknown].
ContributionStatus contributionStatusFromApi(String? value) => switch (value) {
  'Pending' => ContributionStatus.pending,
  'Paid' => ContributionStatus.paid,
  'Confirmed' => ContributionStatus.confirmed,
  _ => ContributionStatus.unknown,
};
