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
