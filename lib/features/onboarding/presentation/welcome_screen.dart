import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';
import 'package:tallyvel/core/widgets/tallyvel_logo.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_widgets.dart';

/// The first onboarding screen.
class WelcomeScreen extends StatelessWidget {
  /// Creates the screen.
  const WelcomeScreen({
    required this.onGetStarted,
    required this.onSignIn,
    super.key,
  });

  /// Called when the user taps "Get started".
  final VoidCallback onGetStarted;

  /// Called when the user taps "I already have an account".
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          const _DecorativeBars(),
          SafeArea(
            child: Padding(
              padding: onboardingPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const TallyvelLogo.horizontalOnDark(),
                  const Spacer(),
                  const Text(
                    'FOR STOKVELS THAT RUN ON TRUST',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Every contribution, counted.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Log who paid, see whose turn is next, and close each '
                    'cycle with a record the whole group can check. No more '
                    'spreadsheets or WhatsApp screenshots.',
                    style: TextStyle(
                      color: Color(0xFFCFE0DA),
                      fontSize: 17,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip('Made for South African stokvels'),
                      _Chip('Amounts in rand'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  OnboardingButton(
                    label: 'Get started',
                    background: AppColors.gold,
                    foreground: AppColors.text,
                    onPressed: onGetStarted,
                  ),
                  const SizedBox(height: 12),
                  OnboardingButton(
                    label: 'I already have an account',
                    outlined: true,
                    onPressed: onSignIn,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

/// Three faint tally bars behind the headline.
class _DecorativeBars extends StatelessWidget {
  const _DecorativeBars();

  @override
  Widget build(BuildContext context) {
    final color = Colors.white.withValues(alpha: 0.08);
    Widget bar(double right, double height) => Positioned(
      right: right,
      top: 120,
      child: Container(
        width: 44,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
    return ExcludeSemantics(
      child: Stack(children: [bar(128, 300), bar(62, 360), bar(-4, 420)]),
    );
  }
}
