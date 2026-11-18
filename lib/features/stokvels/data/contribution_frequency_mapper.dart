import 'package:tallyvel/features/stokvels/domain/contribution_frequency.dart';

/// Reads the API's frequency: exactly `Weekly`, `BiWeekly` or `Monthly`.
/// Anything else is [ContributionFrequency.unknown].
ContributionFrequency contributionFrequencyFromApi(String? value) =>
    switch (value) {
      'Weekly' => ContributionFrequency.weekly,
      'BiWeekly' => ContributionFrequency.biWeekly,
      'Monthly' => ContributionFrequency.monthly,
      _ => ContributionFrequency.unknown,
    };
