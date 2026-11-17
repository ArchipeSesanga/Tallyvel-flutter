import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/theme/app_theme.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';

import 'provider_harness.dart';

/// Pumps [screen] in the app's own theme on a phone-sized view, signed in as
/// [persona], and settles it.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Persona persona,
}) async {
  tester.view.physicalSize = const Size(780, 1688);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: fakeWorldAs(persona),
      child: MaterialApp(theme: AppTheme.light, home: screen),
    ),
  );
  await tester.pumpAndSettle();
}
