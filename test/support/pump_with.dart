import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/theme/app_theme.dart';

/// Pumps [screen] once, in the app's own theme on a phone-sized view, inside a
/// `ProviderScope` whose failing providers are NOT retried
/// (`retry: (_, _) => null`).
///
/// Riverpod retries a failed provider by default, with growing delays. A
/// failure test would then sit in "loading" and leave timers behind; with
/// retry off, one `pump()` shows the failure.
Future<void> pumpWith(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
}
