import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/time/format_date.dart';
import 'package:tallyvel/core/widgets/view_state_body.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/presentation/home_providers.dart';
import 'package:tallyvel/features/memberships/presentation/role_label.dart';

/// The Home tab: one card per stokvel, with the person's own numbers.
/// Pull down to refresh; the cards stay while it reloads.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(homeProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      // TEMPORARY, for the Sentry demo: remove before release.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: () {
              throw StateError('This is test exception');
            },
            child: const Text('Verify Sentry Setup'),
          ),
        ),
      ),
      body: ViewStateBody(
        state: homeViewStateOf(ref.watch(homeProvider)),
        onRetry: notifier.refresh,
        empty: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            key: const Key('home-empty'),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 48),
              Text(
                "You're not in a stokvel yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 12),
              Text(
                'Create one, or ask a member to send you an invite link and '
                'open it on this phone.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (cards) => RefreshIndicator(
          onRefresh: notifier.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [for (final card in cards) _StokvelCard(card: card)],
          ),
        ),
      ),
    );
  }
}

class _StokvelCard extends StatelessWidget {
  const _StokvelCard({required this.card});

  final HomeCard card;

  @override
  Widget build(BuildContext context) {
    final due = card.currentCycle?.endsOn;
    return Card(
      key: Key('home-card-${card.stokvelId}'),
      child: ListTile(
        onTap: () => StokvelRoute(id: card.stokvelId).go(context),
        title: Text(card.name),
        subtitle: Text(
          'Paid ${formatRand(card.paidThisCycle)} · '
          'Owe ${formatRand(card.owedThisCycle)}'
          '${due == null ? '' : ' · Due ${formatDate(due)}'}',
        ),
        trailing: Chip(label: Text(roleLabel(card.role))),
      ),
    );
  }
}
