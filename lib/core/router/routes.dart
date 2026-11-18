/// Central place for every route path and name in the app.
abstract final class AppRoutes {
  /// Bottom-nav tab: Home.
  static const home = AppRoute('/home', 'home');

  /// Bottom-nav tab: Stokvels.
  static const stokvels = AppRoute('/stokvels', 'stokvels');

  /// Bottom-nav tab: Activity.
  static const activity = AppRoute('/activity', 'activity');

  /// Bottom-nav tab: Profile.
  static const profile = AppRoute('/profile', 'profile');
}

/// A route's path and name.
class AppRoute {
  /// Creates a route description.
  const AppRoute(this.path, this.name);

  /// Full path used with `context.go(...)` and as the initial location.
  final String path;

  /// Name used with `context.goNamed(...)`.
  final String name;
}
