import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/activity/data/fake_activity_repository.dart';
import 'package:tallyvel/features/activity/domain/activity_repository.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/contributions/data/fake_contributions_repository.dart';
import 'package:tallyvel/features/contributions/domain/contributions_repository.dart';
import 'package:tallyvel/features/cycles/data/fake_cycles_repository.dart';
import 'package:tallyvel/features/cycles/domain/cycles_repository.dart';
import 'package:tallyvel/features/home/data/fake_home_repository.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/memberships/data/fake_memberships_repository.dart';
import 'package:tallyvel/features/memberships/domain/memberships_repository.dart';
import 'package:tallyvel/features/stokvels/data/fake_stokvels_repository.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

part 'composition_root.g.dart';

/// The composition root: the only place that decides which implementation
/// answers each repository interface.
///
/// Screens and their providers import the repository *providers* below, which
/// are typed as the domain interfaces. They never import a `data/` class, so
/// swapping the fakes for the real API changes this file and nothing else.

/// The fake world, built once. Tests override it to pin the date.
@Riverpod(keepAlive: true)
SeedWorld seedWorld(Ref ref) => SeedWorld(now: DateTime.now());

/// The id of the signed-in person in the fake world.
///
/// Signed out, this is an id nobody has, so every fake answers "nothing" and
/// no screen has to handle a missing user: the router moves a signed-out
/// person away from them anyway.
@riverpod
String signedInUserId(Ref ref) => switch (ref.watch(authProvider)) {
  SignedIn(:final persona) => switch (persona) {
    Persona.lerato => SeedWorld.leratoId,
    Persona.sipho => SeedWorld.siphoId,
    Persona.thandi => SeedWorld.thandiId,
  },
  SignedOut() => 'nobody',
};

/// Answers the home screen.
@riverpod
HomeRepository homeRepository(Ref ref) => FakeHomeRepository(
  ref.watch(seedWorldProvider),
  ref.watch(signedInUserIdProvider),
);

/// Answers which stokvels the person is in, and as what.
@riverpod
MembershipsRepository membershipsRepository(Ref ref) =>
    FakeMembershipsRepository(
      ref.watch(seedWorldProvider),
      ref.watch(signedInUserIdProvider),
    );

/// Answers the stokvels list and each stokvel's page.
@riverpod
StokvelsRepository stokvelsRepository(Ref ref) => FakeStokvelsRepository(
  ref.watch(seedWorldProvider),
  ref.watch(signedInUserIdProvider),
);

/// Answers a stokvel's cycles.
@riverpod
CyclesRepository cyclesRepository(Ref ref) => FakeCyclesRepository(
  ref.watch(seedWorldProvider),
  ref.watch(signedInUserIdProvider),
);

/// Answers a stokvel's contributions.
@riverpod
ContributionsRepository contributionsRepository(Ref ref) =>
    FakeContributionsRepository(
      ref.watch(seedWorldProvider),
      ref.watch(signedInUserIdProvider),
    );

/// Answers the activity feed.
@riverpod
ActivityRepository activityRepository(Ref ref) => FakeActivityRepository(
  ref.watch(seedWorldProvider),
  ref.watch(signedInUserIdProvider),
);
