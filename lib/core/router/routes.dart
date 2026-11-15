/// Central place for every route path and name in the app.
abstract final class AppRoutes {
  // Bottom-nav tabs (shell branches)
  static const home = AppRoute('/home', 'home');
  static const stokvels = AppRoute('/stokvels', 'stokvels');
  static const activity = AppRoute('/activity', 'activity');
  static const profile = AppRoute('/profile', 'profile');
}

class AppRoute {
  const AppRoute(this.path, this.name);

  /// Full path used with `context.go(...)` and as the initial location.
  final String path;

  /// Name used with `context.goNamed(...)`.
  final String name;
}
 