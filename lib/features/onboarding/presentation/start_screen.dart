import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';
import 'package:tallyvel/core/widgets/tallyvel_logo.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_widgets.dart';

/// How the user chose to begin.
enum OnboardingOutcome {
  /// Create a new stokvel as treasurer.
  createStokvel,

  /// Join an existing stokvel with an invite.
  joinWithInvite,

  /// Sign in to an existing account.
  signIn,
}

/// The final onboarding screen: create or join a stokvel.
class StartScreen extends StatefulWidget {
  /// Creates the screen.
  const StartScreen({
    required this.onBack,
    required this.onFinished,
    super.key,
  });

  /// Called when the back arrow is tapped.
  final VoidCallback onBack;

  /// Called with the user's choice.
  final ValueChanged<OnboardingOutcome> onFinished;

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  OnboardingOutcome _choice = OnboardingOutcome.createStokvel;

  @override
  Widget build(BuildContext context) {
    final creating = _choice == OnboardingOutcome.createStokvel;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: onboardingPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const TallyvelLogo.horizontal(height: 28),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How do you want to start?',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You can belong to more than one stokvel. Add another any '
                'time.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _ChoiceCard(
                icon: Icons.add,
                iconTint: AppColors.greenTint,
                iconColor: AppColors.green,
                title: 'Start a new stokvel',
                body:
                    "Set the amount and cycle, then invite members. You'll be "
                    'the treasurer.',
                selected: creating,
                onTap: () =>
                    setState(() => _choice = OnboardingOutcome.createStokvel),
              ),
              const SizedBox(height: 12),
              _ChoiceCard(
                icon: Icons.person_add_alt,
                iconTint: AppColors.goldTint,
                iconColor: AppColors.goldDark,
                title: 'Join with an invite',
                body: 'Got a link or code from your treasurer? Paste it here.',
                selected: !creating,
                onTap: () =>
                    setState(() => _choice = OnboardingOutcome.joinWithInvite),
              ),
              const Spacer(),
              OnboardingButton(
                label: creating ? 'Create my stokvel' : 'Join my stokvel',
                onPressed: () => widget.onFinished(_choice),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => widget.onFinished(OnboardingOutcome.signIn),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.iconTint,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color iconTint;
  final Color iconColor;
  final String title;
  final String body;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(
        color: selected ? AppColors.green : AppColors.border,
        width: selected ? 2 : 1,
      ),
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: Material(
        color: Colors.white,
        shape: shape,
        elevation: selected ? 3 : 0,
        shadowColor: const Color(0x33000000),
        child: InkWell(
          customBorder: shape,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: iconTint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SizedBox.square(
                    dimension: 44,
                    child: Icon(icon, color: iconColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        body,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: selected ? AppColors.green : AppColors.track,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
