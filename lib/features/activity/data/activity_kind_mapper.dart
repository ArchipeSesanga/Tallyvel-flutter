import 'package:tallyvel/features/activity/domain/activity_kind.dart';

/// Reads the API's activity kind: exactly `ContributionRecorded`,
/// `PayoutMade` or `MemberJoined`. Anything else is [ActivityKind.unknown].
ActivityKind activityKindFromApi(String? value) => switch (value) {
  'ContributionRecorded' => ActivityKind.contributionRecorded,
  'PayoutMade' => ActivityKind.payoutMade,
  'MemberJoined' => ActivityKind.memberJoined,
  _ => ActivityKind.unknown,
};
