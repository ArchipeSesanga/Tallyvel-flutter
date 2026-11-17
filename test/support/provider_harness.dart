import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

/// A fixed "now" so the seed's cycle label and dates never depend on the day
/// the tests run.
final testNow = DateTime.utc(2026, 11, 17, 15);

/// An [Auth] that starts in a given state and needs no sign-in screen.
class FixedAuth extends Auth {
  /// Creates an auth that starts as [initial].
  FixedAuth(this.initial);

  /// The state it starts in.
  final AuthState initial;

  @override
  AuthState build() => initial;
}

/// Overrides that put the fake world on [testNow] and sign in as [persona]
/// (or nobody, when `null`).
///
/// The fakes answer with no delay unless [latency] says otherwise.
List<Override> fakeWorldAs(
  Persona? persona, {
  FakeLatency latency = FakeLatency.none,
}) => [
  seedWorldProvider.overrideWithValue(SeedWorld(now: testNow)),
  fakeLatencyProvider.overrideWithValue(latency),
  authProvider.overrideWith(
    () => FixedAuth(persona == null ? const SignedOut() : SignedIn(persona)),
  ),
];

/// A container signed in as [persona], disposed by the caller.
ProviderContainer containerAs(Persona? persona) =>
    ProviderContainer(overrides: fakeWorldAs(persona));
