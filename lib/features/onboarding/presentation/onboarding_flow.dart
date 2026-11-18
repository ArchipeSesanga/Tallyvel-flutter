import 'package:flutter/material.dart';
import 'package:tallyvel/features/onboarding/presentation/intro_pager_screen.dart';
import 'package:tallyvel/features/onboarding/presentation/start_screen.dart';
import 'package:tallyvel/features/onboarding/presentation/welcome_screen.dart';

/// The onboarding flow: welcome, three intro pages, then create or join.
///
/// Owns its own [Navigator], so it can be shown as the app's `home` and
/// replaced wholesale once [onFinished] fires.
class OnboardingFlow extends StatefulWidget {
  /// Creates the flow.
  const OnboardingFlow({required this.onFinished, super.key});

  /// Called when the user makes a final choice.
  final ValueChanged<OnboardingOutcome> onFinished;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  void _push(Widget screen) {
    _navigatorKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _pop() => _navigatorKey.currentState!.pop();

  void _showStart() =>
      _push(StartScreen(onBack: _pop, onFinished: widget.onFinished));

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => WelcomeScreen(
          onGetStarted: () => _push(
            IntroPagerScreen(onBackFromFirst: _pop, onDone: _showStart),
          ),
          onSignIn: () => widget.onFinished(OnboardingOutcome.signIn),
        ),
      ),
    );
  }
}
