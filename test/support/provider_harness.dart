import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/contributions/data/fake_contributions_repository.dart';
import 'package:tallyvel/features/cycles/data/fake_cycles_repository.dart';
import 'package:tallyvel/features/home/data/fake_home_repository.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/memberships/data/fake_memberships_repository.dart';
import 'package:tallyvel/features/stokvels/data/fake_stokvels_repository.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

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
///
/// The repositories are the fakes, because the app's own come from the API.
/// A test that needs a stub passes it as [home] or [stokvels] (a provider
/// cannot be overridden twice).
List<Override> fakeWorldAs(
  Persona? persona, {
  FakeLatency latency = FakeLatency.none,
  HomeRepository? home,
  StokvelsRepository? stokvels,
}) => [
  seedWorldProvider.overrideWithValue(SeedWorld(now: testNow)),
  fakeLatencyProvider.overrideWithValue(latency),
  // The app answers from the API; tests answer from the fake world.
  if (home != null)
    homeRepositoryProvider.overrideWithValue(home)
  else
    homeRepositoryProvider.overrideWith(
      (ref) => FakeHomeRepository(
        ref.watch(seedWorldProvider),
        ref.watch(signedInUserIdProvider),
        ref.watch(fakeLatencyProvider),
      ),
    ),
  membershipsRepositoryProvider.overrideWith(
    (ref) => FakeMembershipsRepository(
      ref.watch(seedWorldProvider),
      ref.watch(signedInUserIdProvider),
      ref.watch(fakeLatencyProvider),
    ),
  ),
  if (stokvels != null)
    stokvelsRepositoryProvider.overrideWithValue(stokvels)
  else
    stokvelsRepositoryProvider.overrideWith(
      (ref) => FakeStokvelsRepository(
        ref.watch(seedWorldProvider),
        ref.watch(signedInUserIdProvider),
        ref.watch(fakeLatencyProvider),
      ),
    ),
  cyclesRepositoryProvider.overrideWith(
    (ref) => FakeCyclesRepository(
      ref.watch(seedWorldProvider),
      ref.watch(signedInUserIdProvider),
      ref.watch(fakeLatencyProvider),
    ),
  ),
  contributionsRepositoryProvider.overrideWith(
    (ref) => FakeContributionsRepository(
      ref.watch(seedWorldProvider),
      ref.watch(signedInUserIdProvider),
      ref.watch(fakeLatencyProvider),
    ),
  ),
  authProvider.overrideWith(
    () => FixedAuth(persona == null ? const SignedOut() : SignedIn(persona)),
  ),
];

/// A container signed in as [persona], disposed by the caller.
ProviderContainer containerAs(Persona? persona) =>
    ProviderContainer(overrides: fakeWorldAs(persona));
