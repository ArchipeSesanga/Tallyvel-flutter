# Tallyvel

Tallyvel mobile app (Flutter, Android and iOS).

## Project structure

```
lib/
  main.dart                      entry point only (calls runApp)
  app/                           the app widget, router and theme (app-wide wiring)
  core/                          shared building blocks used by several features
    money/                       the Cents type, formatter and parser
    config/                      reading the per-flavour config
  features/
    home/
      domain/                    models + repository interfaces (pure Dart, no Flutter imports)
      data/                      repository implementations (fakes now, the real API later)
      presentation/              widgets, screens and their providers
    stokvel_detail/
      domain/                    models + repository interfaces (pure Dart, no Flutter imports)
      data/                      repository implementations (fakes now, the real API later)
      presentation/              widgets, screens and their providers
```

**The rule that matters most:** `presentation/` never imports a `data/` implementation.
It depends on `domain/` interfaces only. This will be enforced later with providers
and, optionally, a test.

## Flavours and config (Android and iOS)

Three flavours, installable side by side:

| Flavour | Application id | Launcher name | Config |
|---|---|---|---|
| `dev` | `za.co.archipe.tallyvel.dev` | Tallyvel Dev | `config/dev.json` |
| `staging` | `za.co.archipe.tallyvel.staging` | Tallyvel Staging | `config/staging.json` |
| `prod` | `za.co.archipe.tallyvel` | Tallyvel | `config/prod.json` |

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
