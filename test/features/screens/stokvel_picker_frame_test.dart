import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/auth/domain/auth_state.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_providers.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_screen.dart';

import '../../support/provider_harness.dart';
import '../../support/pump_with.dart';

/// A title in the app bar, not the same words in the picker's menu.
Finder _inAppBar(String text) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(text));

// `exists` is marked deprecated in favour of `provider.exist`, which the
// generated family providers do not offer yet. It answers the one question the
// test needs: has anyone asked for B's page?
bool _exists(ProviderContainer container) =>
    // The replacement is not available on generated families (see above).
    // ignore: deprecated_member_use
    container.exists(stokvelPageProvider(SeedWorld.workId));

void main() {
  testWidgets(
    'the frame test: switching to a slow stokvel shows ITS loading state in '
    'the very next frame, and nothing of the stokvel it came from',
    (tester) async {
      // Stokvel B (Work) is slow; A (Family) answers at once.
      await pumpWith(
        tester,
        const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
        overrides: fakeWorldAs(
          Persona.lerato,
          latency: const FakeLatency(
            perStokvel: {SeedWorld.workId: Duration(seconds: 2)},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Lerato is looking at A, with its contributions on screen.
      expect(find.text('Family Stokvel'), findsOneWidget);
      expect(find.text('Lindiwe Dube'), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(StokvelDetailScreen)),
      );
      expect(
        _exists(container),
        isFalse,
        reason: 'B has not been asked for yet',
      );

      // She picks B in the app bar.
      await tester.tap(find.byKey(const Key('stokvel-picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('pick-${SeedWorld.workId}')));

      // ONE frame, no settling.
      await tester.pump();

      // The picker changed which family id the screen watches...
      expect(_exists(container), isTrue);
      // ...so the screen is on B's loading state, not on A's data.
      expect(find.byKey(const Key('loading')), findsOneWidget);
      expect(
        find.text('Lindiwe Dube'),
        findsNothing,
        reason: "A's contributions",
      );
      expect(
        find.text('Thabo Nkosi'),
        findsNothing,
        reason: "A's contributions",
      );
      // (The closing menu still names both stokvels, so look in the app bar.)
      expect(_inAppBar('Family Stokvel'), findsNothing);
      expect(_inAppBar('Work Stokvel'), findsNothing, reason: 'B is not here');

      // When B arrives it replaces the spinner. (Its page asks the slow
      // stokvel twice in a row: first the page, then cycles and contributions
      // together, so two delays.)
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.byKey(const Key('loading')), findsNothing);
      expect(_inAppBar('Work Stokvel'), findsOneWidget);
      expect(find.text('Nomsa Khumalo'), findsOneWidget);
      expect(find.text('Lindiwe Dube'), findsNothing);
    },
  );

  testWidgets('the picker marks the current stokvel and is off with one', (
    tester,
  ) async {
    await pumpWith(
      tester,
      const StokvelDetailScreen(stokvelId: SeedWorld.familyId),
      overrides: fakeWorldAs(Persona.lerato),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('stokvel-picker')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('pick-${SeedWorld.familyId}')), findsOneWidget);
    expect(find.byKey(const Key('pick-${SeedWorld.workId}')), findsOneWidget);
    final checked = tester.widget<CheckedPopupMenuItem<String>>(
      find.byKey(const Key('pick-${SeedWorld.familyId}')),
    );
    expect(checked.checked, isTrue);
  });
}
