import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tallyvel/core/theme/app_colors.dart';
import 'package:tallyvel/core/widgets/tallyvel_logo.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_pages.dart';
import 'package:tallyvel/features/onboarding/presentation/onboarding_widgets.dart';

class _IntroPage {
  const _IntroPage({
    required this.card,
    required this.title,
    required this.body,
  });

  final Widget card;
  final String title;
  final String body;
}

const _pages = [
  _IntroPage(
    card: WhoHasPaidCard(),
    title: 'See who has paid, at a glance.',
    body:
        'The treasurer records each contribution once. Every member sees the '
        'same list, so nobody has to chase screenshots in the group chat.',
  ),
  _IntroPage(
    card: PayoutRotationCard(),
    title: 'Everyone knows whose turn is next.',
    body:
        'The group agrees the order once. TallyVel shows the next payout and '
        'closes each cycle only when the numbers add up.',
  ),
  _IntroPage(
    card: MoneyStaysYoursCard(),
    title: 'We keep the tally. You keep the money.',
    body:
        "TallyVel never moves or holds your funds. It's a shared record your "
        'whole stokvel can trust.',
  ),
];

/// The three intro pages with Skip, back and Next controls.
class IntroPagerScreen extends StatefulWidget {
  /// Creates the screen.
  const IntroPagerScreen({
    required this.onBackFromFirst,
    required this.onDone,
    super.key,
  });

  /// Called when back is pressed on the first page.
  final VoidCallback onBackFromFirst;

  /// Called on Skip or after the last page.
  final VoidCallback onDone;

  @override
  State<IntroPagerScreen> createState() => _IntroPagerScreenState();
}

class _IntroPagerScreenState extends State<IntroPagerScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _duration = Duration(milliseconds: 300);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (_index == 0) {
      widget.onBackFromFirst();
    } else {
      await _controller.previousPage(
        duration: _duration,
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _next() async {
    if (_index == _pages.length - 1) {
      widget.onDone();
    } else {
      await _controller.nextPage(duration: _duration, curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_back());
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: onboardingPadding,
                child: SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_index == 0)
                        const TallyvelLogo.symbol(height: 30)
                      else
                        IconButton(
                          tooltip: 'Back',
                          onPressed: _back,
                          icon: const Icon(Icons.arrow_back),
                        ),
                      TextButton(
                        onPressed: widget.onDone,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) => _PageBody(page: _pages[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Row(
                  children: [
                    _Dots(count: _pages.length, index: _index),
                    const Spacer(),
                    SizedBox(
                      width: 150,
                      child: OnboardingButton(
                        label: isLast ? "Let's go" : 'Next',
                        trailing: Icons.arrow_forward,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final _IntroPage page;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: onboardingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          page.card,
          const SizedBox(height: 32),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 30,
              height: 1.12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            page.body,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 17,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Page ${index + 1} of $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 6),
              width: i == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == index ? AppColors.green : AppColors.track,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
        ],
      ),
    );
  }
}
