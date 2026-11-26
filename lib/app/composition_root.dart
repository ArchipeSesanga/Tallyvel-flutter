import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/core/config/app_config.dart';
import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/network/api_client.dart';
import 'package:tallyvel/core/observability/error_reporter.dart';
import 'package:tallyvel/features/activity/data/fake_activity_repository.dart';
import 'package:tallyvel/features/activity/domain/activity_repository.dart';
import 'package:tallyvel/features/auth/data/api_auth_repository.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/domain/auth_repository.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/contributions/data/api_contributions_repository.dart';
import 'package:tallyvel/features/contributions/domain/contributions_repository.dart';
import 'package:tallyvel/features/cycles/data/api_cycles_repository.dart';
import 'package:tallyvel/features/cycles/domain/cycles_repository.dart';
import 'package:tallyvel/features/home/data/api_home_repository.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/memberships/data/api_memberships_repository.dart';
import 'package:tallyvel/features/memberships/domain/memberships_repository.dart';
import 'package:tallyvel/features/stokvels/data/api_stokvels_repository.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

part 'composition_root.g.dart';

/// The composition root: the only place that decides which implementation
/// answers each repository interface.
///
/// Screens and their providers import the repository *providers* below, which
/// are typed as the domain interfaces. They never import a `data/` class, so
/// swapping the fakes for the real API changes this file and nothing else.

/// The app's config. Overridden in `main` once read; a test that needs the
/// network overrides what uses it instead.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) =>
    throw UnimplementedError('Override appConfigProvider in main.');

/// Where errors worth a developer's attention go. Overridden in `main`.
@Riverpod(keepAlive: true)
ErrorReporter errorReporter(Ref ref) => const NoopReporter();

/// The access token, in memory.
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore();

/// The one [Dio] for the API, from the config's base URL.
@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) => createApiDio(
  baseUrl: ref.watch(appConfigProvider).apiBaseUrl,
  tokens: ref.watch(tokenStoreProvider),
  // The access token ended (about 15 minutes): back to sign-in.
  onUnauthorised: () => ref.read(authProvider.notifier).signOut(),
);

/// Signs in and out against the real API.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    ApiAuthRepository(ref.watch(apiDioProvider), ref.watch(tokenStoreProvider));

/// The fake world, built once. Tests override it to pin the date.
@Riverpod(keepAlive: true)
SeedWorld seedWorld(Ref ref) => SeedWorld(now: DateTime.now());

/// How long the fakes take to answer. A third of a second, so the app shows
/// its loading states the way it will with a network; tests override it with
/// [FakeLatency.none] (or make one stokvel slow).
@Riverpod(keepAlive: true)
FakeLatency fakeLatency(Ref ref) =>
    const FakeLatency(base: Duration(milliseconds: 350));

/// The id of the signed-in person: the API's id for a real sign-in, the fake
/// world's id for a fake or test one.
///
/// Signed out, this is an id nobody has, so every fake answers "nothing" and
/// no screen has to handle a missing user: the router moves a signed-out
/// person away from them anyway.
@riverpod
String signedInUserId(Ref ref) => switch (ref.watch(authProvider)) {
  SignedIn(:final userId?) => userId,
  SignedIn(:final persona) => switch (persona) {
    Persona.lerato => SeedWorld.leratoId,
    Persona.sipho => SeedWorld.siphoId,
    Persona.thandi => SeedWorld.thandiId,
    // An account with no fake data: every fake answers "nothing".
    null => 'nobody',
  },
  SignedOut() => 'nobody',
};

/// Answers the home screen, from the API.
@riverpod
HomeRepository homeRepository(Ref ref) =>
    ApiHomeRepository(ref.watch(apiDioProvider));

/// Answers which stokvels the person is in, and as what, from the API.
@riverpod
MembershipsRepository membershipsRepository(Ref ref) =>
    ApiMembershipsRepository(ref.watch(apiDioProvider));

/// Answers the stokvels list and each stokvel's page, from the API.
@riverpod
StokvelsRepository stokvelsRepository(Ref ref) =>
    ApiStokvelsRepository(ref.watch(apiDioProvider));

/// Answers a stokvel's cycles, from the API.
@riverpod
CyclesRepository cyclesRepository(Ref ref) =>
    ApiCyclesRepository(ref.watch(apiDioProvider));

/// Answers a stokvel's contributions, from the API.
@riverpod
ContributionsRepository contributionsRepository(Ref ref) =>
    ApiContributionsRepository(ref.watch(apiDioProvider));

/// Answers the activity feed. Still the fake world: the API's
/// `GET /me/activity` is not wired yet.
@riverpod
ActivityRepository activityRepository(Ref ref) => FakeActivityRepository(
  ref.watch(seedWorldProvider),
  ref.watch(signedInUserIdProvider),
  ref.watch(fakeLatencyProvider),
);
