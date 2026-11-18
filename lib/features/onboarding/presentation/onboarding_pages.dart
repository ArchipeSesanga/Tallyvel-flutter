import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';
import 'package:tallyvel/core/widgets/tallyvel_logo.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_widgets.dart';

/// Page 1: who has paid.
class WhoHasPaidCard extends StatelessWidget {
  /// Creates the card.
  const WhoHasPaidCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Family stokvel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'November cycle · R500 each',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                'R1 500 of R2 500',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.6,
              minHeight: 8,
              color: AppColors.green,
              backgroundColor: AppColors.border,
            ),
          ),
          const SizedBox(height: 8),
          const _MemberRow(
            initials: 'LM',
            name: 'Lerato M.',
            detail: 'Paid 2 Nov · EFT',
            status: 'Paid',
            tint: AppColors.greenTint,
            ink: AppColors.green,
          ),
          const _MemberRow(
            initials: 'SN',
            name: 'Sipho N.',
            detail: 'Paid 4 Nov · cash',
            status: 'Paid',
            tint: AppColors.greenTint,
            ink: AppColors.green,
          ),
          const _MemberRow(
            initials: 'TK',
            name: 'Thandi K.',
            detail: 'Due 25 Nov',
            status: 'Pending',
            tint: AppColors.goldTint,
            ink: AppColors.goldDark,
          ),
          const _MemberRow(
            initials: 'BD',
            name: 'Bongani D.',
            detail: 'October not recorded',
            status: 'Missed',
            tint: AppColors.redTint,
            ink: AppColors.red,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.initials,
    required this.name,
    required this.detail,
    required this.status,
    required this.tint,
    required this.ink,
    this.showDivider = true,
  });

  final String initials;
  final String name;
  final String detail;
  final String status;
  final Color tint;
  final Color ink;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: tint,
              child: Text(
                initials,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    detail,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            StatusPill(label: status, background: tint, foreground: ink),
          ],
        ),
      ),
    );
  }
}

/// Page 2: payout rotation.
class PayoutRotationCard extends StatelessWidget {
  /// Creates the card.
  const PayoutRotationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Payout rotation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              StatusPill(
                label: 'Order locked',
                icon: Icons.lock_outline,
                background: AppColors.blueTint,
                foreground: AppColors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _TimelineRow(
            marker: _Marker.done,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lerato M. · October',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Received R2 500 · confirmed by 5 members',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          _TimelineRow(
            marker: _Marker.next,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6E5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.goldTint),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEXT PAYOUT',
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      'Sipho N. · 28 November',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'R1 000 still to collect',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const _TimelineRow(
            marker: _Marker.upcoming,
            child: Text(
              'Thandi K. · December',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ),
          const _TimelineRow(
            marker: _Marker.upcoming,
            isLast: true,
            child: Text(
              'Bongani D. · January',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Marker { done, next, upcoming }

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.marker,
    required this.child,
    this.isLast = false,
  });

  final _Marker marker;
  final Widget child;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dot = switch (marker) {
      _Marker.done => const CircleAvatar(
        radius: 14,
        backgroundColor: AppColors.green,
        child: Icon(Icons.check, size: 16, color: Colors.white),
      ),
      _Marker.next => const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.goldTint,
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: CircleAvatar(radius: 14, backgroundColor: AppColors.gold),
        ),
      ),
      _Marker.upcoming => const DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.fromBorderSide(
            BorderSide(color: AppColors.track, width: 2),
          ),
        ),
        child: SizedBox.square(dimension: 28),
      ),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 38,
            child: Column(
              children: [
                SizedBox(width: 38, height: 38, child: Center(child: dot)),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: marker == _Marker.done
                          ? AppColors.green
                          : AppColors.track,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: marker == _Marker.next ? 0 : 6,
                bottom: isLast ? 0 : 14,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Page 3: trust and privacy.
class MoneyStaysYoursCard extends StatelessWidget {
  /// Creates the card.
  const MoneyStaysYoursCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingCard(
      color: AppColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TallyvelLogo.symbolOnDark(height: 40),
          SizedBox(height: 20),
          _Reassurance(
            icon: Icons.account_balance_outlined,
            title: 'Your money stays in your bank',
            body:
                'TallyVel only keeps the record. Contributions go between '
                'members the way they always have.',
          ),
          _Reassurance(
            icon: Icons.fact_check_outlined,
            title: 'Proof of payment, kept private',
            body:
                'Attach a slip to any contribution. Only members of that '
                'stokvel can open it.',
          ),
          _Reassurance(
            icon: Icons.schedule,
            title: 'Every change is on the record',
            body:
                'Only the treasurer or chairperson can record payments, and '
                'each one shows who logged it and when.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _Reassurance extends StatelessWidget {
  const _Reassurance({
    required this.icon,
    required this.title,
    required this.body,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SizedBox.square(
              dimension: 36,
              child: Icon(icon, color: AppColors.gold, size: 20),
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
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFCFE0DA),
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
