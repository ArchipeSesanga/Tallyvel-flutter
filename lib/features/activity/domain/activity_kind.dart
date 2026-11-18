/// What happened.
enum ActivityKind {
  /// Someone's contribution was recorded.
  contributionRecorded,

  /// A cycle was paid out.
  payoutMade,

  /// Someone joined a stokvel.
  memberJoined,

  /// Something this version of the app does not know.
  unknown,
}
