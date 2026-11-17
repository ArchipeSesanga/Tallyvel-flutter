/// What a person is in one stokvel. The same person can hold a different role
/// in each stokvel they belong to.
enum MemberRole {
  /// An ordinary member.
  member,

  /// Runs the money: opens and closes cycles, pays out.
  treasurer,

  /// Created the stokvel; may do everything a treasurer may.
  chairperson,

  /// A role this version of the app does not know (the API added one).
  unknown;

  /// Whether the API lets this role do treasurer actions (open a cycle, close
  /// one, pay out). The API's rule is "Treasurer or Chairperson".
  bool get canRunTreasurerActions => switch (this) {
    treasurer || chairperson => true,
    member || unknown => false,
  };
}
