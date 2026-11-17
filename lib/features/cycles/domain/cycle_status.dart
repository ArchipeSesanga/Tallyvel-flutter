/// Where a collection period stands.
enum CycleStatus {
  /// Contributions are coming in.
  open,

  /// Its last day has passed.
  closed,

  /// Its money went to the recipient.
  paidOut,

  /// A status this version of the app does not know.
  unknown,
}
