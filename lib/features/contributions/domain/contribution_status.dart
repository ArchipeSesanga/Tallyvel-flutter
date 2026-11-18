/// Where a contribution is in its life.
enum ContributionStatus {
  /// Announced, not yet paid. Does not count towards a cycle's total.
  pending,

  /// Paid by the member.
  paid,

  /// Confirmed as received by the treasurer.
  confirmed,

  /// A status this version of the app does not know.
  unknown;

  /// Whether a contribution in this status counts towards what a cycle has
  /// collected. The API's rule: only Paid and Confirmed count.
  bool get countsTowardsTotal => switch (this) {
    paid || confirmed => true,
    pending || unknown => false,
  };
}
