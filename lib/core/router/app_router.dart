import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/core/router/app_shell.dart';
import 'package:tallyvel/core/router/auth_redirect.dart';
import 'package:tallyvel/features/activity/presentation/activity_screen.dart';
import 'package:tallyvel/features/auth/data/auth_provider.dart';
import 'package:tallyvel/features/auth/presentation/sign_in_screen.dart';
import 'package:tallyvel/features/home/presentation/home_screen.dart';
import 'package:tallyvel/features/profile/presentation/profile_screen.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/cycle_screen.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_screen.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_screen.dart';

part 'app_router.g.dart';

/// The app's router. Routes are generated into `$appRoutes`.
///
/// Re-runs [redirect] whenever the auth state changes.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authChanged = ValueNotifier<int>(0);
  ref
    ..listen(authProvider, (_, _) => authChanged.value++)
    ..onDispose(authChanged.dispose);
  final router = GoRouter(
    initialLocation: const HomeRoute().location,
    routes: $appRoutes,
    refreshListenable: authChanged,
    redirect: (context, state) => redirect(
      auth: ref.read(authProvider),
      location: state.uri,
      remembered: state.uri.queryParameters['from'],
    ),
  );
  ref.onDispose(router.dispose);
  return router;
}

/// The fake sign-in page. [from] is the page to return to afterwards.
@TypedGoRoute<SignInRoute>(path: signInPath)
class SignInRoute extends GoRouteData with $SignInRoute {
  /// Creates the route, optionally remembering [from].
  const SignInRoute({this.from});

  /// The page to go back to after signing in.
  final String? from;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const SignInScreen();
}

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(
      routes: [TypedGoRoute<HomeRoute>(path: '/home')],
    ),
    TypedStatefulShellBranch<StokvelsBranch>(
      routes: [
        TypedGoRoute<StokvelsRoute>(
          path: '/stokvels',
          routes: [
            TypedGoRoute<StokvelRoute>(
              path: ':id',
              routes: [TypedGoRoute<CycleRoute>(path: 'cycles/:cycleId')],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<ActivityBranch>(
      routes: [TypedGoRoute<ActivityRoute>(path: '/activity')],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [TypedGoRoute<ProfileRoute>(path: '/profile')],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state,
          StatefulNavigationShell navigationShell) =>
      AppShell(navigationShell: navigationShell);
}

class HomeBranch extends StatefulShellBranchData { const HomeBranch(); }
class StokvelsBranch extends StatefulShellBranchData { const StokvelsBranch(); }
class ActivityBranch extends StatefulShellBranchData { const ActivityBranch(); }
class ProfileBranch extends StatefulShellBranchData { const ProfileBranch(); }

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class StokvelsRoute extends GoRouteData with $StokvelsRoute {
  const StokvelsRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const StokvelsScreen();
}

class ActivityRoute extends GoRouteData with $ActivityRoute {
  const ActivityRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ActivityScreen();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProfileScreen();
}

class StokvelRoute extends GoRouteData with $StokvelRoute {
  const StokvelRoute({required this.id});
  final String id;
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      StokvelDetailScreen(stokvelId: id);
}

// A child route carries its parent's parameters too.
class CycleRoute extends GoRouteData with $CycleRoute {
  const CycleRoute({required this.id, required this.cycleId});
  final String id;
  final String cycleId;
  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CycleScreen(stokvelId: id, cycleId: cycleId);
}
