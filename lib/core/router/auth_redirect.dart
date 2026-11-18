import 'package:tallyvel/features/auth/domain/auth_state.dart';

/// Path of the sign-in page, the only page open to signed-out users.
const signInPath = '/sign-in';

/// Where signed-in users go when there is no valid page to return to.
const homePath = '/home';

final _knownRoutes = <RegExp>[
  RegExp(r'^/home$'),
  RegExp(r'^/stokvels$'),
  RegExp(r'^/stokvels/[^/]+$'),
  RegExp(r'^/stokvels/[^/]+/cycles/[^/]+$'),
  RegExp(r'^/activity$'),
  RegExp(r'^/profile$'),
];

/// Whether [location] is a safe in-app page to return to after signing in:
/// it starts with a single `/` and is one of the app's signed-in routes.
bool isReturnable(String? location) {
  if (location == null || !location.startsWith('/')) return false;
  if (location.startsWith('//')) return false;
  final path = Uri.tryParse(location)?.path;
  if (path == null) return false;
  return _knownRoutes.any((r) => r.hasMatch(path));
}

/// The auth gate for the router. Returns where to go instead of [location],
/// or null to stay. [remembered] is the `from` page the sign-in screen was
/// opened with.
String? redirect({
  required AuthState auth,
  required Uri location,
  String? remembered,
}) {
  final onSignIn = location.path == signInPath;
  switch (auth) {
    case SignedOut():
      if (onSignIn) return null;
      return Uri(
        path: signInPath,
        queryParameters: {'from': location.toString()},
      ).toString();
    case SignedIn():
      if (!onSignIn) return null;
      return isReturnable(remembered) ? remembered : homePath;
  }
}
