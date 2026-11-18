/// How long the fake repositories take to answer.
///
/// A real network call is never instant, and a screen that has only ever seen
/// instant answers has never shown its loading state. So the app runs the
/// fakes with a small delay, and a test sets it to [none] (or makes one
/// stokvel slow, to watch a screen move from one stokvel to another).
class FakeLatency {
  /// Creates a latency: [base] for every call, [perStokvel] overriding it for
  /// calls about one stokvel.
  const FakeLatency({this.base = Duration.zero, this.perStokvel = const {}});

  /// No delay at all: the answer is ready in a microtask, with no timer, so a
  /// test needs no extra frames or `pumpAndSettle`.
  static const none = FakeLatency();

  /// The delay for every call that has no entry in [perStokvel].
  final Duration base;

  /// A different delay for calls about the stokvel with this id.
  final Map<String, Duration> perStokvel;

  /// Waits the delay for [stokvelId] (or [base] if it is `null` or has none).
  Future<void> wait([String? stokvelId]) async {
    final delay = perStokvel[stokvelId] ?? base;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }
}
