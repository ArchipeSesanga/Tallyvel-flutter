import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';

/// Horizontal page padding shared by all onboarding screens.
const onboardingPadding = EdgeInsets.symmetric(horizontal: 24);

/// A full-width rounded button in the onboarding style.
class OnboardingButton extends StatelessWidget {
  /// Creates a button.
  const OnboardingButton({
    required this.label,
    required this.onPressed,
    this.background = AppColors.green,
    this.foreground = Colors.white,
    this.trailing,
    this.outlined = false,
    super.key,
  });

  /// The button text.
  final String label;

  /// Called on tap; the button is disabled when null.
  final VoidCallback? onPressed;

  /// Fill colour.
  final Color background;

  /// Text and icon colour.
  final Color foreground;

  /// Optional icon after the label.
  final IconData? trailing;

  /// Draws an outline instead of a fill.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: outlined ? Colors.transparent : background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.track,
          elevation: outlined ? 0 : 3,
          shadowColor: outlined ? Colors.transparent : background,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: outlined
                ? BorderSide(
                    color: foreground.withValues(alpha: 0.35),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(label, textAlign: TextAlign.center)),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Icon(trailing, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

/// A small rounded avatar/pill style tag.
class StatusPill extends StatelessWidget {
  /// Creates a pill.
  const StatusPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    super.key,
  });

  /// The pill text.
  final String label;

  /// Fill colour.
  final Color background;

  /// Text colour.
  final Color foreground;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The white rounded card used for onboarding illustrations.
class OnboardingCard extends StatelessWidget {
  /// Creates a card around [child].
  const OnboardingCard({
    required this.child,
    this.color = Colors.white,
    super.key,
  });

  /// The card content.
  final Widget child;

  /// Card colour.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}
