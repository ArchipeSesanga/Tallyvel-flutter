import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/time/format_date.dart';
import 'package:tallyvel/core/widgets/async_body.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/presentation/home_providers.dart';
import 'package:tallyvel/features/memberships/presentation/role_label.dart';

/// The Home tab: one card per stokvel, with the person's own numbers.
class HomeScreen extends ConsumerWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Home')),
    body: AsyncBody(
      value: ref.watch(homeViewProvider),
      data: (view) => switch (view) {
        HomeEmpty() => const Center(
          key: Key('home-empty'),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('You are not in a stokvel yet.'),
          ),
        ),
        HomeLoaded(:final cards) => ListView(
          padding: const EdgeInsets.all(16),
          children: [for (final card in cards) _StokvelCard(card: card)],
        ),
      },
    ),
  );
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
