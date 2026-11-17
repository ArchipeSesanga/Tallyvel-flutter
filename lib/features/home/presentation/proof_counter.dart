import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'proof_counter.g.dart';

/// A notifier that deliberately breaks `avoid_public_notifier_properties`, to
/// prove CI fails on a Riverpod lint. Never merge this branch.
@riverpod
class ProofCounter extends _$ProofCounter {
  /// A public field on a notifier: this is the violation.
  int publicField = 0;

  @override
  int build() => 0;
}
