import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/theme/app_theme.dart';
import 'package:tallyvel/features/onboarding/data/onboarding_status.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_flow.dart';

/// The root widget of the Tallyvel app.
class TallyvelApp extends ConsumerWidget {
  /// Creates the app.
  const TallyvelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(onboardingStatusProvider);
    if (!onboarded) {
      return MaterialApp(
        title: 'Tallyvel',
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: OnboardingFlow(
          // Sign-in, create and join screens don't exist yet; every
          // outcome just ends onboarding for now.
          onFinished: (_) =>
              ref.read(onboardingStatusProvider.notifier).complete(),
        ),
      );
    }
    return MaterialApp.router(
      title: 'Tallyvel',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
