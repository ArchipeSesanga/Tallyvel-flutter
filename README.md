# TallyVel

TallyVel mobile app (Flutter, Android and iOS).

## Project structure

```
lib/
  main.dart                      entry point only (calls runApp)
  app/                           the app widget and the composition root
    composition_root.dart        the ONE place that picks which implementation answers each repository
  core/                          shared building blocks used by several features
    money/                       Cents (extension type), the rand formatter and parser
    time/                        CalendarDate (South African day, no time zone), date formatting
    paging/                      PageOf<T>: a page whose last page has no next token
    state/                       ViewState: the four states every screen has (loading, empty, failure, data)
    fakes/                       the seed world the fake repositories answer from
    config/                      reading the per-flavour config
    router/, theme/, widgets/    navigation, theme, shared widgets
  features/<feature>/
    domain/                      freezed models, enums with `unknown`, repository interfaces (no Flutter)
    data/                        repository implementations (fakes now, the real API in 11.1)
    presentation/                screens and their providers; a view state is mapped here from AsyncValue
```

Features with a `domain/`: `memberships`, `stokvels`, `cycles`, `contributions`, `home`, `activity`.

**The rule that matters most:** `presentation/` never imports a `data/` implementation.
It reads repository *providers* from `app/composition_root.dart`, which are typed as the
domain interfaces. Swapping the fakes for the real API therefore changes that one file.
`test/architecture/presentation_imports_test.dart` fails if a file under any `presentation/`
folder imports a fake, the fake world, Dio or Drift. (10.3 extends it.)

## Flavours and config (Android and iOS)

Three flavours, installable side by side:

| Flavour | Application id | Launcher name | Config |
|---|---|---|---|
| `dev` | `za.co.archipe.tallyvel.dev` | TallyVel Dev | `config/dev.json` |
| `staging` | `za.co.archipe.tallyvel.staging` | TallyVel Staging | `config/staging.json` |
| `prod` | `za.co.archipe.tallyvel` | TallyVel | `config/prod.json` |

Always pass the flavour and its matching config file:

```
flutter run --flavor dev --dart-define-from-file=config/dev.json
flutter build apk --flavor prod --dart-define-from-file=config/prod.json
```

The config files hold no secrets. The app refuses to start without a config, or
with a config for a different flavour (for example a `prod` build given
`dev.json`); see `test/core/config/app_config_test.dart`.

On iOS each flavour has its own Xcode scheme and build configurations
(`Debug-dev`, `Release-staging`, ...) with the same ids and names as Android.
`flutter build ios --simulator --flavor dev --dart-define-from-file=config/dev.json`
builds without signing.

## Domain and fakes

Money is `Cents` (an extension type over `int`), written `R1 234,50`; the API sends every
amount as integer cents. A due date is a `CalendarDate` (a South African day with no time
zone); an instant stays a UTC `DateTime`. Every status is an enum with an `unknown` case,
and every `switch` over one has no default, so a value the app does not know can never be
mistaken for a known one. A list ends with a page that has no next token; the API's own
marker for that (`""`) stays in the data layer.

Every screen has the same four states, one sealed type (`ViewState`: loading, empty, failure,
data), mapped from Riverpod's `AsyncValue` by `viewStateOf`, so a `switch` over them needs no
default and "no stokvels" is *empty*, never a list that happens to have nothing in it. Home
is an `AsyncNotifier` with pull-to-refresh that keeps the old cards on screen while it
reloads. The stokvel page is a Riverpod family by stokvel id, with a picker in its app bar.
A stokvel the person is not in is "Not found", the same answer as a missing id, because that
is what the API sends (404).

What a person can do on a stokvel's page is decided by one function, `actionsFor`, a single
exhaustive match over (role in THIS stokvel, cycle status, status of my own contribution)
with no wildcard over a status. Its nine rule rows are written above it, each from a rule the
API enforces, and each has one test.

### Personas

The fake repositories answer from `lib/core/fakes/seed_world.dart`, which mirrors the API's
own demo seed (`Infrastructure/Persistence/SeedData.cs` and `DemoAdditions.cs`). The numbers
in the tests are the ones the real API returned on a fresh seed.

| Persona | Email | Family Stokvel (R500) | Work Stokvel (R300) |
|---|---|---|---|
| Lerato Mokoena | `lerato@tallyvel.test` | Treasurer | Member |
| Sipho Zulu | `sipho@tallyvel.test` | Member | Treasurer |
| Thandi Ndlovu | `thandi@tallyvel.test` | not in it | not in it |

**Where is the "Member-only Sipho"?** The 10.3 brief describes Sipho as a plain member
everywhere. The real seed makes him the Treasurer of Work Stokvel, and the fakes follow the
API so that the swap in 11.1 changes nothing on screen. The member-only case is still
covered, twice: Lerato in Work Stokvel and Sipho in Family Stokvel are both ordinary members,
and Thandi is in nothing. The 10.3 persona tests are written against this table.

## Running it

```
# once, and after any change to a model or provider (generated files are not committed)
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# the fake data, in the dev flavour
flutter run --flavor dev --dart-define-from-file=config/dev.json
```

There is one config file per flavour in `config/` (`dev.json`, `staging.json`, `prod.json`),
always passed with `--dart-define-from-file`. The app **refuses to start** without one, and
refuses a config for another flavour than the one it was built as (a `prod` build given
`dev.json`); `test/core/config/app_config_test.dart` proves both. The config holds no
secrets. The fakes answer after 350 ms, so the loading states are visible; tests set the
delay to zero (`FakeLatency.none`) or make one stokvel slow.

The checks CI runs, in its order:

```
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs
dart analyze --fatal-infos
flutter test
```

**Lints.** `very_good_analysis` is the rule set and `riverpod_lint` runs as an analyzer
plugin (`analysis_options.yaml`). CI runs `dart analyze --fatal-infos`, never
`flutter analyze`: only `dart analyze` loads analyzer plugins, so `flutter analyze` does not
run `riverpod_lint` at all and a Riverpod mistake (a public field on a notifier, for
example) passes it silently and fails CI.

## Generated code

`*.g.dart` and `*.freezed.dart` (freezed models, Riverpod providers, typed routes) are
**not committed**; they are in `.gitignore`. Why: they are 100% reproducible from the source,
the pinned `build_runner` and the lockfile, and committing them puts thousands of generated
lines into every diff and conflicts into every merge. What it costs: a fresh clone needs the
one `build_runner` command above before the IDE stops showing errors. CI generates **before**
it analyzes and tests, so generated code can never be stale in CI. (The API client in 11.1 is
the exception: its output is committed, so a drift check can see it change.)

## Money

- An amount is `Cents`, an extension type over `int`: an amount of money cannot be mixed up with
  a count of members, and nothing holds money in a `double`.
- Written the way `en-ZA` writes rand: `R1 234,50`. The group separator is **U+00A0** (a
  non-breaking space, so a number never wraps), the decimal separator is a comma, there are
  always two decimals, a negative reads `-R10,00`. Tests spell it `\u00A0`.
- `parseRand` reads what a person types: `500`, `500.5`, `500,50`, `R 1 234,50`, `0,10`.
  **The full-stop decision:** both `,` and `.` are accepted as the decimal separator (a phone's
  number keypad types a full stop) and never as a thousands separator. So `1.234` and `1,234`
  are *refused*: with three digits it is ambiguous, and guessing wrong moves a decimal point.
  Also refused: empty, a minus sign, two separators (`1,234.50`), `.5`, `12.`, letters, and
  anything over 2^53 - 1 cents (the most the API accepts).

## When the API adds a status

The API's enums are closed sets today (`Open | Closed | PaidOut`, `Pending | Paid | Confirmed`,
`Member | Treasurer | Chairperson`). Here is what happens when one grows, tried for real: I
added `refunded` to `ContributionStatus` and ran `dart analyze --fatal-infos`:

```
error - lib/features/contributions/domain/contribution_status.dart:20:34 - The type 'ContributionStatus' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'ContributionStatus.refunded'. Try adding a wildcard pattern or cases that match 'ContributionStatus.refunded'. - non_exhaustive_switch_expression
  error - lib/features/contributions/presentation/contribution_status_label.dart:4:62 - The type 'ContributionStatus' isn't exhaustively matched by the switch cases since it doesn't match the pattern 'ContributionStatus.refunded'. Try adding a wildcard pattern or cases that match 'ContributionStatus.refunded'. - non_exhaustive_switch_expression
  error - lib/features/stokvel_detail/domain/stokvel_action.dart:56:7 - The type '(MemberRole, CycleStatus, ContributionStatus?)' isn't exhaustively matched by the switch cases since it doesn't match the pattern '(MemberRole.member, CycleStatus.open, ContributionStatus.refunded)'. Try adding a wildcard pattern or cases that match '(MemberRole.member, CycleStatus.open, ContributionStatus.refunded)'. - non_exhaustive_switch_expression

3 issues found.
```

Three places stop compiling, and they are exactly the three places that have to decide what the
new status means: whether it counts towards a total, what it is called on screen, and what a
person can do about it. Nothing else changes and nothing is found by testing. I reverted the
change; the enum has no `refunded`.

**An app that is already installed** does not have that code. The mapper
(`contributionStatusFromApi`) turns any name it does not know into `ContributionStatus.unknown`,
so `Refunded` arrives as `unknown`, never as a crash and never as a status it might be mistaken
for: the screen says "Unknown", it does not count towards a total, and `actionsFor` grants
nothing for it. The same holds for roles, cycle statuses, frequencies and activity kinds. Totals
are summed by the API, so an old install still shows the right numbers.

## Provider lifetimes

`@riverpod` providers dispose when nothing listens; `keepAlive` ones live as long as the app.
The rule: **anything that holds a person's data is not kept alive**, so signing out cannot
leave one person's numbers for the next.

| Provider | Holds | Lifetime | Cost of keeping it | Cost of disposing it |
|---|---|---|---|---|
| `seedWorldProvider` | the fake world (people, stokvels, contributions) | keepAlive | a few KB | the "server" forgets its data and clock; only the fakes have this |
| `fakeLatencyProvider` | one delay setting | keepAlive | nothing | nothing |
| `authProvider` | who is signed in | keepAlive | none, it must outlive every screen | the app forgets the person on every rebuild |
| `appRouterProvider` | the router and its stack | keepAlive | none, there must be one | the navigation stack is lost |
| `onboardingStatusProvider`, `sharedPreferencesProvider` | "onboarding done" and the prefs handle | keepAlive | nothing | an onboarded person is shown onboarding again |
| `*RepositoryProvider` (six) | a thin object over the fake world | autoDispose | nothing | rebuilt on next use: free |
| `signedInUserIdProvider` | the id the fakes answer as | autoDispose | stale id after sign-out | recomputed: free |
| `homeProvider` | the home cards | autoDispose | stale money after a payment elsewhere | spinner and a refetch when Home is shown again |
| `stokvelPageProvider(id)` | one page: detail, cycles, 20 contributions | autoDispose, per id | one page per stokvel ever opened, with numbers that go stale | reopening shows a spinner and a refetch, with correct numbers |
| `myStokvelsProvider`, `activityFeedProvider` | a list | autoDispose | stale list | refetch |

**Proof of one disposal.** `test/features/presentation/providers_test.dart` listens to two
stokvel pages, closes one listener, and checks that exactly one disposal was logged, for that
id, and none for the other. What is logged is the provider name and its family argument only
(`stokvelPageProvider(stokvel-family)`): ids, never a name or an amount (POPIA).

**At sign-out.** Because nothing that holds a person's data is kept alive, signing out needs no
cleanup of those providers: `signedInUserIdProvider` changes, every provider that watches it is
rebuilt for the next person, and the autoDispose ones are gone anyway. The kept-alive providers
hold no person's data. Anything that ever does must be `ref.invalidate`d in the sign-out path;
with the real API (11.1) that includes the in-memory token holder.

## Tests

```
dart format --output=none --set-exit-if-changed .
dart run build_runner build --delete-conflicting-outputs   # generated files are not committed
dart analyze --fatal-infos
flutter test
```

## Contract notes

What the real API sends, found by reading its code and calling it. API repo
`ArchipeSesanga/TallyVel`, branch `dev`, commit `014980ee70d9ac210800296a20de61364c409ec1`,
probed on 2026-11-17 on a fresh seed. The mapper and Failure code in 11.1 is written
against these answers, not against another API's.

- API repo: `ArchipeSesanga/TallyVel`, branch `dev`, commit `014980ee70d9ac210800296a20de61364c409ec1`
- Probed on 2026-11-17 against `docker compose down -v && docker compose up -d --build` (fresh seed, API on `localhost:8080`).
- Every "curl" below was run for real against that stack. Tokens, cookies and the seed password are not recorded here.
- The API was torn down afterwards (`docker compose down -v`).

### 0. Source of truth for the contract

| Question | Answer | Evidence |
|---|---|---|
| Is `clients/typescript/openapi.json` what the API serves and tests against? | **No.** It is a derived snapshot, exported by hand. | See below. |
| What is the source of truth? | The OpenAPI document that ASP.NET generates at runtime from the controllers and DTOs: `GET /openapi/v1.json`. | `Api/Program.cs:68` `AddOpenApi(...)`, `Api/Program.cs:327` `MapOpenApi()`. `Microsoft.AspNetCore.OpenApi` 10.0.12 (`Api/Api.csproj:14`). |
| Is there a build-time `openapi/v1.json`? | **No.** There is no `Microsoft.Extensions.ApiDescription.Server` and no build step that writes a file. | `grep ApiDescription Api/*.csproj Tests/*.csproj` finds nothing. |
| Is it served in production? | **No.** Only when `ASPNETCORE_ENVIRONMENT=Development`. | `Api/Program.cs:325-327`. |
| What do the tests read? | The served document from the in-process test host. They write the snapshot only if `OPENAPI_OUTPUT` is set. | `Tests/Contract/OpenApiDocumentTests.cs:17` reads `/openapi/v1.json`; line 24 checks `OPENAPI_OUTPUT`. |
| Does API CI check the snapshot is fresh? | **No.** `.github/workflows/ci.yml` never mentions openapi, contract or typescript. | `grep -in "openapi\|contract\|typescript" .github/workflows/ci.yml` finds nothing. |

Snapshot history: `clients/typescript/openapi.json` was last changed by `944c74a0c16ec26be0c4bcb997952865aa751441` (2026-11-09).

#### `contract/v1.json` (app) vs the current API

- `contract/v1.json` is byte-identical to `clients/typescript/openapi.json` at `944c74a` **and** at API HEAD `014980e` (SHA-256 `08ed639f…8a0d` for all three; the file did not change in the 41 commits between).
- The live served document (`/openapi/v1.json`, normalised with `jq -S`) differs from that snapshot in **one string**: the description of `DELETE /api/v1/stokvels/{id}/members/{userId}`.
  - Snapshot: "Removes the member. Refuses to remove the last admin, …"
  - Served: "Removes the member. **Anyone may remove THEMSELVES (leave the stokvel); removing someone else is for a Chairperson.** Refuses to remove the last admin, …"
  - Cause: `Api/Presentation/Controllers/StokvelController.cs` changed after the last export (5 lines added, 2 removed) and the snapshot was not regenerated.
- No path, schema, enum, status code or required field differs. The generated client would be identical.
- Consequence: the snapshot has already drifted once, silently. For 11.1 CI the cross-repo diff must compare against a file that is regenerated, not the committed snapshot, or the API repo needs a CI check that fails when the snapshot is stale (gap G3).

### 1. How a page ends

- The end marker is `nextPageToken == ""` (empty string). It is never `null` and never missing.
- The schema says so: `PagedResponseOfContributionResponse.required = ["items","nextPageToken"]`, `nextPageToken: {"type":"string"}` (not nullable). Doc comment: `Api/Application/Contracts/PagedResponse.cs:3-8`.
- Evidence (curl, Lerato, Family Stokvel has 4 contributions):
  - `?pageSize=2` → 200, `nextPageToken` is a long opaque base64 string.
  - `?pageSize=2&pageToken=<that>` → 200, `"nextPageToken":""`.
  - `?pageSize=100` → `{"n":4,"nextPageToken":"","hasKey":true}`.
- `GET /me/activity` pages the same way (`PagedResponseOfActivityItem`); it returned a token at `pageSize=2`.
- A token reused with other filters → **400**, not 404/409/422:
  `{"type":"tag:tallyvel,2026:problem/page-token-filter-mismatch","title":"Invalid Query","status":400,"detail":"This page token was issued for a different filter or sort. Start again from the first page.","code":"page-token-filter-mismatch","correlationId":"…"}`
  (token made with default sort, reused with `sort=amount`).
- A garbage token → 400, `code: "invalid-pagetoken"`, detail "Invalid page token."
- `pageSize=-1` → 400, `code: "PageSize.Negative"`. `pageSize` 0 or missing → 20; above 100 → clamped to 100 (`Paging.cs:7-17`).
- Mapper rule: "no more pages" ⇔ `nextPageToken.isEmpty`.
- `GET /stokvels`, `GET /stokvels/{id}/cycles` and `GET /me/home` are **not** paged (plain array / object).

### 2. Stale-write guard

- It is a **`version` field in the body**, not an ETag. There is **no** `ETag`, `If-Match` or 412 anywhere in the API.
  - `grep -rn "ETag\|If-Match\|IfMatch\|412\|PreconditionFailed" Api --include=*.cs` finds nothing.
  - `GET /stokvels/{id}` responds with no `ETag` header.
- The only guarded write is closing a cycle:
  1. `GET /stokvels/{id}/cycles/{cycleId}/close-preview` returns `version` (opaque string, 64 hex chars, in `required`). `Api/Application/Contracts/CycleDtos.cs:27-39`.
  2. `POST …/close` with body `{"version":"<that>"}` and an `Idempotency-Key` header (required).
- Stale version → **409**, `code: "close-preview-stale"`, `title: "Already Exists"` (sic), detail "Something changed since you looked (a payment, a member or the date). Nothing was closed. Review the new preview and try again."
  - curl: `POST …/close` with `{"version":"stale"}` → `[HTTP 409]`.
- Already closed → 409 `cycle-already-closed` (from the controller doc, `CyclesController.cs:108-112`; not exercised in this run).
- Missing `Idempotency-Key` → **400** `code: "invalid-argument"`, detail "An Idempotency-Key header is required."
- Mapper rule: 409 → `ConflictFailure(detail)`. 412 is never sent, so it is not mapped to anything special. The app keeps `version` exactly as sent and tells conflicts apart by `code`, not by `title` (the 409 title is "Already Exists" for both stale and in-progress).

### 3. Exact spelling of every status

All enums are sent as PascalCase **names** (`JsonStringEnumConverter`, README line 1191). From the served document, `components.schemas`:

| Thing | Values, exactly |
|---|---|
| Cycle status (`CycleStatus`) | `Open`, `Closed`, `PaidOut` |
| Contribution status (`ContributionStatus`) | `Pending`, `Paid`, `Confirmed` |
| Role (`MemberRole`) | `Member`, `Treasurer`, `Chairperson` |
| Payout status | **There is none.** `PayoutResponse` has no status field. A payout exists, or it does not; the cycle becomes `PaidOut`. |
| Frequency (`ContributionFrequency`) | `Weekly`, `BiWeekly`, `Monthly` |
| Activity kind (`ActivityKind`) | `ContributionRecorded`, `PayoutMade`, `MemberJoined` |

- Seen live: home `role: "Treasurer"`, `currentCycle.status: "Open"`, contribution `status: "Paid"`.
- Numbers are still accepted on input, never sent.
- Dates and money on the wire (needed by the mappers):
  - Money: integer `long` cents, fields end in `Cents` (`amountCents`, `paidThisCycleCents`, …).
  - Instants: UTC ending in `Z`, e.g. `"recordedAt":"2026-10-31T22:30:00Z"`.
  - Calendar dates: `"2026-11-30"`, South African dates (`startsOn`, `endsOn`, `nextPayoutDate`, `asOfDate`). Some are nullable.
  - Cycle `label` is a string like `"2026-11"`, and a contribution's `cycle` field is that same label.
- Note: `GET /stokvels/{id}/cycles` returns only `{id, stokvelId, label, status}`. No dates. Dates come from `/me/home` and `GET /stokvels/{id}` (`currentCycle.endsOn`).

### 4. Refresh cookie, access token lifetime, reuse grace window

- Cookie name: **`tallyvel_rt`**. Attributes (curl `Set-Cookie`): `expires=` +7 days, `path=/api/v1/auth`, **`secure`**, `samesite=strict`, `httponly`. `AuthController.cs:16-18,111-118`.
- The refresh token is **not** in the body. Login returns only `{"accessToken": "...", "expiresAt": "..."}` (`AccessTokenResponse`, both required).
- Access token lifetime: **15 minutes** (`JwtOptions.AccessTokenMinutes = 15`, `Api/Common/JWTOptions.cs:10`). curl: login at 17:11:02Z → `expiresAt` 17:26:02Z.
- Refresh token lifetime: 7 days (`RefreshTokenDays = 7`).
- **Reuse grace window: none.** Presenting an already-used refresh token revokes the whole token family at once (`AuthService.cs:99-104`). There is no tolerance for a retry after a lost response.
  - curl: refresh with cookie A → 200 and new cookie B. Refresh with A again, 0 s later → **401**. Then refresh with B → **401** (family revoked).
  - 401 body: `detail: "Your session is invalid or has expired. Please sign in again."`
- Consequence for a phone: a refresh whose response is lost on a flaky network kills the session (G1).
- Consequence for the dev flavour: the cookie is `Secure`, and the emulator talks to `http://10.0.2.2`. A spec-following cookie jar will not send it over http. 11.1 keeps the access token in memory only and signs in again; refresh is out of scope for 11.1 (G1).

### 5. Does every error carry `correlationId`, and does the schema declare it?

- **Declared:** yes. `ProblemDetails` and `ValidationProblemDetails` both have `correlationId` (`["null","string"]`, "The reference a member can quote to support. Also written to the server log.") and `traceId`.
- **Not declared:** `code` (the machine-readable reason, e.g. `close-preview-stale`) is **not** in either schema, and `Retry-After` is not declared (G2). The mapper must read the raw body for `code` and `correlationId`.
- **Sent:** every JSON error I triggered had a `correlationId`:
  - 400 (validation `errors{}`, page-token, negative pageSize, malformed JSON), 401 (no token, bad login, bad refresh), 403, 404 (non-member, unknown id, unknown route), 405, 409 (stale version, already recorded), 415, 422, 429, 500.
  - 405 and unknown-route 404 are `application/problem+json` too.
- The id equals the request's W3C trace id, and a caller's `traceparent` is honoured: sent `traceparent: 00-0af7651916cd43dd8448eb211c80319c-…` → `correlationId: "0af7651916cd43dd8448eb211c80319c"`. `Api/Observability/Correlation.cs`.
- The 500's id is findable in the API log: the id from a 500 appeared in 3 log lines (`docker compose logs api | grep <id>`), one of them `Request <id> failed with 500`.
- **Exception:** `/health/live` and `/health/ready` return `text/plain` (`Unhealthy`, 503) with no `correlationId`. They are not part of the client contract (README line 1081).
- Not exercised: 410, 413 (the handler maps them, `TallyVelExceptionHandler.cs`).
- A proxy in front (HTML 502/504) would have no `correlationId`, and the `500` field is the generic message "Something went wrong on our side. Quote the correlationId if you report this."

### 6. Non-member vs member without the role

Policy, `StokvelControllerBase.AuthorizeStokvelAsync` (lines 15-30): not a member → **404** (does not confirm the stokvel exists); a member without the needed role → **403**.

| Caller | Route | Result |
|---|---|---|
| Thandi (in no stokvel) | `GET /stokvels/{family}/contributions` | **404**, `title: "Not Found"`, no `detail`, has `correlationId` |
| Thandi | `GET /stokvels/{family}/cycles/{id}/close-preview` (treasurer action) | **404** |
| Lerato (Member of Work) | `GET /stokvels/{work}/cycles/{id}/close-preview` | **403**, `title: "Forbidden"`, no `detail`, has `correlationId` |
| Lerato (Member of Work) | `POST /stokvels/{work}/cycles` (open cycle) | **403** |
| Lerato (Treasurer of Family) | `GET /stokvels/{family}/cycles/{id}/close-preview` | 200 |
| Lerato | `GET /stokvels/00000000-0000-0000-0000-000000000000/contributions` | **404**, identical to the non-member case |
| Lerato | `GET /stokvels/abc/contributions` (not a guid) | 404 |
| nobody | `GET /me/home` without a token | **401** |

- A 404 for a missing stokvel and for "not a member" are indistinguishable by design, so the app's NotFound screen is the same for both.
- 403 and 404 bodies have `type`, `title`, `status`, `traceId`, `correlationId` and **no `detail`**.
- Also seen: `POST /stokvels` with a `creatorId` other than the caller → 403.
- Seed personas, from `Infrastructure/Persistence/SeedData.cs` and `DemoAdditions.cs`, confirmed with `/me/home`:
  - Lerato (`lerato@tallyvel.test`): Treasurer of Family Stokvel, Member of Work Stokvel.
  - **Sipho (`sipho@tallyvel.test`): Member of Family Stokvel and Treasurer of Work Stokvel** (live `/me/home`: Family = Member, Work = Treasurer). This is **not** "Member only" (G5).
  - Thandi (`thandi@tallyvel.test`): in no stokvel; one valid invite and one expired invite.
  - The password is the API's `SEED_DEMO_PASSWORD` (`compose.yaml`, `Seed__DemoPassword`). Not recorded here.

### 7. Rate limiting and `Retry-After`

Only three policies exist (`Api/Common/RateLimitPolicies.cs`, README 1070-1130):

| Policy | Endpoints (file:line) | Limit | Partition |
|---|---|---|---|
| `login` | `POST /auth/login` (`AuthController.cs:64`) | 5 per 60 s, fixed window (compose default; `LOGIN_RATE_LIMIT` raises it) | IP |
| `money` | `POST …/contributions` (`ContributionsController.cs:122`), `POST …/contributions/{id}/proof` (`ContributionProofsController.cs:43`), `POST …/cycles/{id}/payout` (`CyclesController.cs:67`), `POST …/cycles/{id}/close` (`CyclesController.cs:106`) | token bucket: 30 tokens, +10 per 60 s | user (`sub`) |
| `invite-guess` | `GET /invites/{code}` (`InvitesController.cs:41`), `POST /invites/{code}/join` (`:55`) | 10 per 60 s | user |

Nothing else is rate limited (reads, `/me/*`, `refresh`, `register`, `logout`).

- Every rejection is **429**, `application/problem+json`, `title: "Too Many Requests"`, `type: https://tools.ietf.org/html/rfc6585#section-4`, `detail` "Too many requests. Wait the number of seconds in the Retry-After header, then try again.", with `correlationId`.
- `Retry-After` is **whole seconds**, an integer, not an HTTP date. curl: `Retry-After: 60`.
  - Login: 4 earlier sign-ins in the same minute had used the window; the next one was 200, the following six were 429, each with `Retry-After: 60`.
  - Money: 30 requests spent the bucket (all 409 "already recorded", each still costs a token); request 31 and 32 → 429, `Retry-After: 60`. Three seconds later → still `Retry-After: 60`.
- So `Retry-After` is the **replenishment period, a constant 60**, not the time left. It does not count down. The UI text "Try again in 60 seconds" is honest as an upper bound.
- The header is **not declared** in `openapi/v1.json` (no `headers` on any 429 response), and no `securitySchemes` are declared (G2).
- A 429 happens before any controller runs, so it never consumes the idempotency key (README section 5).

### Timings for the Dio timeouts (Step 3)

Measured with `curl -w %{time_total}` against `GET /api/v1/me/home` (needs the DB) with a valid token. The compose service is `postgres`, not `db`.

| Scenario | Result |
|---|---|
| `docker compose stop postgres` (DB container gone) | **500** in 0.088 s, 0.146 s, 0.015 s. Anonymous `POST /auth/login`: 500 in 0.012 s. `/health/ready` 503 in 0.012 s. |
| `docker compose pause postgres` (DB blackholed, connection hangs) | **500** after **15.04 s**. `/health/ready` 503 after 15.02 s. |

- The 15 s is Npgsql's default connection `Timeout` (nothing overrides it: `Api/Program.cs:122-125` has no `CommandTimeout` and no connection-string timeout). The `/health/ready` check has its own 3 s limit (`Program.cs:51`), yet it took 15 s here, so that limit did not apply.
- **The API does not retry inside.** `Program.cs:122-125` calls `UseNpgsql(connectionString, o => o.MigrationsAssembly(...))` with no `EnableRetryOnFailure`; a stopped DB fails in tens of milliseconds, so there is no hidden retry loop. → The app must **not** retry a 500 either (a retry cannot help sooner than a person's "try again"), and a write must never be retried.
- **Recorded for 11.1 (G9):** the 15 s above is the longest the API takes to give up on its database, and `/health/ready` takes the same 15 s although it is meant to cap at 3 s. The timeouts in 11.1 are built on this number.
- Timeout implication: the app's `receiveTimeout` must be **above 15 s** (say 20 s), otherwise it gives up one second before the API would have answered with a 500 that carries the `correlationId`.
- The 500 body is the generic `internal-error` problem with `correlationId` (log lookup works).

### Gaps

| # | Gap | Why it matters | Suggested fix, in the API repo, own branch + PR + tests |
|---|---|---|---|
| G1 **(decided: held for 11.2, the auth day)** | Refresh needs a `Secure` cookie and has **no reuse grace window**; the refresh token is not in the body | A phone on http (dev) cannot refresh; a lost refresh response revokes the session. | Decide first. 11.1 sidesteps it: in-memory access token, sign in again after 15 min. A real fix is a short grace window and/or a mobile token flow. |
| G2 **(fixed in API PR #19, not merged yet)** | The OpenAPI document declares neither `Retry-After` on 429, nor `code` on `ProblemDetails`, nor a bearer `securityScheme` | The generated client cannot expose them; the app reads the raw body and header instead (already the plan). | Add a response header + `code` extension + bearer scheme in the OpenAPI transformer, with a test in `OpenApiDocumentTests`. |
| G3 **(fixed in API PR #19, not merged yet)** | `clients/typescript/openapi.json` can go stale, and API CI does not check it. It is already stale by one description (§0) | The app's drift check compares against it. | Add an API CI step: regenerate with `OPENAPI_OUTPUT` and `git diff --exit-code`. Until then the app's cross-repo check should use the freshly generated document, not the committed snapshot. |
| G4 **(decided: fixed in API PR #21, not merged yet)** | "Who is next" is **not sent**, and there is no list-payouts endpoint | Payout screens can only know `recipientUserId` from `POST …/payout`'s response or from `PayoutMade` rows in `/me/activity`. `GET /stokvels/{id}/cycles` has no dates and no payout info. | Add `GET /stokvels/{id}/payouts` and/or a `nextRecipientUserId` on the stokvel detail, or confirm the 10.3 payouts layer works from `/me/activity` only. |
| G5 **(decided: the app follows the API)** | The real seed has Sipho as Treasurer of Work Stokvel, not "Member only" | The persona list in your 10.1 spec ("Sipho: Member only") disagrees with the API. | None in the API. The fake persona for Sipho follows the API (Member of Family, Treasurer of Work); see Personas. |
| G6 **(fixed in API PR #20, not merged yet)** | `Retry-After` is the constant window length (60), not the time remaining | The "Try again in N seconds" text overstates the wait. | Optional: send the real remaining seconds. |
| G7 | The 409 title is `"Already Exists"` for stale versions and in-progress requests | Clients must use `code`, which is not in the schema (G2). | Optional: titles per code. |
| G8 **(held: the evidence says this is by design; see below)** | A payout on a still-**Open** cycle succeeded (201, 100 010 cents) when I tried it by mistake on the seed | Unrelated to 11.1's contract, but it looks like a business-rule gap. | Confirm whether payout is meant to need a Closed cycle. |
| G9 **(decided: recorded, no fix)** | `/health/ready` is not capped at 3 s while the DB hangs (took 15 s) | Only matters for orchestration, but the 15 s is the number 11.1's timeouts are built on (see Timings). | None now. |

**G1, planned fix (11.2).** The refresh cookie is `Secure` and `SameSite=Strict`, and there is no
reuse grace window. When the auth work starts: turn `Secure` off **only in Development** (so the
emulator's `http://10.0.2.2` can carry it), and add a short grace window for a refresh token that
was just used, so a lost response does not revoke the whole login. Until then the app keeps the
access token in memory and signs in again after 15 minutes.

**G4, what the endpoint will give the payouts screen.** PR #21 adds
`GET /api/v1/stokvels/{id}/cycles/{cycleId}/payouts`: the order is decided by the server (members
by join time, then user id), each entry has `position`, `amountCents`, `paidAt`, `status`
(`PaidOut | Next | Upcoming`) and `isNext`, and the response has `nextMemberId` (null once everyone
has been paid). Any member may read it; a non-member gets 404. It lands before 10.3.

**G8, the evidence.** The API deliberately allows a payout on an open cycle. (1) The cycle entity
says "A Payout pays the cycle's money out, independently of closing" (`Domain/Entities/ContributionCycle.cs:23`).
(2) The endpoint says it "Pays the cycle's total contributions to one member and closes the cycle"
(`CyclesController.cs:69`): paying out is what moves a cycle to `PaidOut`, with or without the
nightly close. (3) Three API tests pay out a never-closed cycle and expect 201
(`ApiReadinessTests.A_payout_comes_back_in_cents`, `ApiReadinessTests.Every_timestamp_in_every_kind_of_response_ends_in_Z`,
`MetricTests.A_payout_is_counted_with_its_outcome`). *Against that:* `ApiReadinessTests.A_cycle_is_Open_then_Closed_then_PaidOut`
walks the lifecycle in the order the belief expects and pays out only after the close, and the status
names read as a sequence. That shows the intended *story*, but the test closes first by choice;
nothing refuses a payout before it. (4) Nothing in the README or
`docs/` says a payout needs a closed cycle. So the rule "only after the cycle is closed" is not
what the API does and not what it documents. The app's `actionsFor` therefore offers a payout on an
open cycle (row 5/6) and on a closed one (row 7), and not after it has been paid out. Held: changing
the API's rule is a product decision.

**G6, what changed.** The built-in limiters report the whole window as `Retry-After` however much
has passed (measured: `60`, still `60` three seconds later). PR #20 wraps them so it is the time left.

G8 mutated the fresh seed (one payout row) while probing. The stack was destroyed with `down -v` afterwards, so the next `up -d` starts clean.

### Endpoints the app will call (11.1 `include_paths`)

`POST /auth/login`, `GET /me/home`, `GET /stokvels`, `GET /stokvels/{id}`, `GET /stokvels/{id}/cycles`, `GET /stokvels/{id}/contributions`, `POST /stokvels/{id}/contributions`, `GET /stokvels/{id}/cycles/{cycleId}/close-preview`, `POST /stokvels/{id}/cycles/{cycleId}/close`, `POST /stokvels/{id}/cycles/{cycleId}/payout`, `GET /me/activity`. Invites only if the onboarding "join" is wired.
