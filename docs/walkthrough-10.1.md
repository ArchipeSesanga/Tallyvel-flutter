# TallyVel 10.1: Foundations and State, walkthrough

Branch `assignment-10.1-domain-and-fakes`, PR #1. No network: every screen talks to a
repository interface, and one file decides those interfaces are fakes.

**The one-sentence story:** in 11.1 the real API replaces the fakes in
[composition_root.dart](../lib/app/composition_root.dart) and no widget changes.

Run it: `flutter run --flavor dev --dart-define-from-file=config/dev.json`
(after `dart run build_runner build --delete-conflicting-outputs`).

## Where is the stokvel card?

There is no public `StokvelCard` class. The card on Home is the private widget
`_StokvelCard` at [home_screen.dart:60](../lib/features/home/presentation/home_screen.dart#L60),
built inside [HomeScreen](../lib/features/home/presentation/home_screen.dart#L13).
The data it shows is `HomeCard` in [home_card.dart](../lib/features/home/domain/home_card.dart):
only the signed-in person's own numbers. The same card is covered by
[home_states_test.dart](../test/features/screens/home_states_test.dart).

## Follow one screen from the top: Home

Read these in order, each is a layer deeper.

1. Screen: [home_screen.dart](../lib/features/home/presentation/home_screen.dart): a
   `ConsumerWidget`, no data logic.
2. State: [home_providers.dart](../lib/features/home/presentation/home_providers.dart): `Home` is an
   `AsyncNotifier`; `refresh()` keeps the old cards on screen while it reloads.
   `homeViewStateOf` maps it to a `ViewState`.
3. The four states: [view_state.dart](../lib/core/state/view_state.dart) (Loading, Empty, Failure, Data)
   and [view_state_body.dart](../lib/core/widgets/view_state_body.dart) which draws them.
4. Interface: [home_repository.dart](../lib/features/home/domain/home_repository.dart).
5. Fake: [fake_home_repository.dart](../lib/features/home/data/fake_home_repository.dart), reading
   [seed_world.dart](../lib/core/fakes/seed_world.dart).
6. Wiring: [composition_root.dart](../lib/app/composition_root.dart).

## Follow the second screen: Stokvel page

- Screen with the app-bar picker and the actions card:
  [stokvel_detail_screen.dart](../lib/features/stokvel_detail/presentation/stokvel_detail_screen.dart)
  (`_StokvelPicker` at line 74).
- A provider family keyed by stokvel id, `null` meaning "not found":
  [stokvel_detail_providers.dart](../lib/features/stokvel_detail/presentation/stokvel_detail_providers.dart).
- What the page is made of: [stokvel_page.dart](../lib/features/stokvel_detail/domain/stokvel_page.dart).
- What the person may do:
  [stokvel_action.dart](../lib/features/stokvel_detail/domain/stokvel_action.dart): `actionsFor(role, cycle, mine)`
  is one exhaustive match with 9 documented rows.

## The domain

| Topic | Code | Say |
|---|---|---|
| Money | [cents.dart](../lib/core/money/cents.dart) | Integer cents, never a double |
| Rand format and parse | [rand_format.dart](../lib/core/money/rand_format.dart) | `R1 234,50` with U+00A0; parser accepts `,` and `.` as the decimal separator only; refuses `1.234` |
| Dates | [calendar_date.dart](../lib/core/time/calendar_date.dart), [format_date.dart](../lib/core/time/format_date.dart) | South African day (UTC+2), no off-by-one |
| Paging | [page.dart](../lib/core/paging/page.dart) | The last page has a null token |
| Statuses | `lib/features/*/domain/*_status.dart` plus `lib/features/*/data/*_mapper.dart` | Every enum has `unknown`; switches have no wildcard, so a new status breaks the build |
| Fakes | [seed_world.dart](../lib/core/fakes/seed_world.dart), [fake_latency.dart](../lib/core/fakes/fake_latency.dart) | Mirrors the real seed; 350 ms in the app, zero in tests |

Personas: Lerato is Treasurer of Family and Member of Work; Sipho is Member of Family and
Treasurer of Work; Thandi is in neither. The README Personas table explains why this covers
"Member-only Sipho".

## Guard rails

- No widget imports a fake, Dio or Drift:
  [presentation_imports_test.dart](../test/architecture/presentation_imports_test.dart).
- "When the API adds a status": README section with the real analyzer output (I added `refunded`
  and got 3 `non_exhaustive_switch_expression` errors).
- Lints and CI: CI runs `dart analyze --fatal-infos`. Branch `ci-proof/10.1-public-notifier-field` is the
  deliberate red run: `dart analyze` fails with `avoid_public_notifier_properties`, while
  `flutter analyze` says "No issues found" because it never loads the riverpod_lint plugin.
- Exact dependency pins, no `^`; generated files are not committed and CI generates them first.

## Tests to open

| What it proves | File |
|---|---|
| Slow stokvel B cannot overwrite the page after a switch (breaking the picker makes it fail) | [stokvel_picker_frame_test.dart](../test/features/screens/stokvel_picker_frame_test.dart) |
| One fetch for two listeners, one disposal, only that page | [providers_test.dart](../test/features/presentation/providers_test.dart) |
| Each state of each screen | [home_states_test.dart](../test/features/screens/home_states_test.dart), [stokvel_detail_states_test.dart](../test/features/screens/stokvel_detail_states_test.dart), [list_screens_states_test.dart](../test/features/screens/list_screens_states_test.dart) |
| One test per row of the actions rule | [stokvel_action_test.dart](../test/features/stokvel_detail/stokvel_action_test.dart) |
| Money cases | [cents_test.dart](../test/core/money/cents_test.dart) |
| Status mapping | [status_mapping_test.dart](../test/features/data/status_mapping_test.dart) |
| ViewState mapping | [view_state_test.dart](../test/core/state/view_state_test.dart) |

143 tests pass; `dart format` and `dart analyze --fatal-infos` are clean.

## Suggested order for presenting (about 15 minutes)

1. The story and the composition root (1 min).
2. Domain and money (4 min).
3. Home, top to bottom, with the card (3 min), then show it on the device.
4. Stokvel page: picker, family, actions (3 min).
5. Guard rails, including the red run (2 min).
6. Open the frame test last (2 min).

## Decisions and likely questions

- **Why fakes?** 10.1 is foundations; 11.1 swaps the data layer behind the same interfaces.
- **Why a family for the stokvel page?** Each id has its own state, so switching never shows
  the wrong stokvel.
- **Why `dart analyze` in CI?** `flutter analyze` skips the Riverpod lints (see the red run).
- **Payout before close (G8):** not changed. The evidence mostly says it is by design; the
  decision is the owner's. See README Contract notes.
- **Contract notes:** README records what the real API does (page end `""`, body `version` as the
  stale-write guard, cookie rules, 15 s blackholed-DB timeout).

## Still to add before presenting

- Screenshots: Home (Lerato), Home empty, picker open, loading, failure and retry.
- The red CI run link (GitHub has not run CI yet because `ci.yml` is not on `main`).
