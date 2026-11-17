import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/time/format_date.dart';
import 'package:tallyvel/core/widgets/async_body.dart';
import 'package:tallyvel/features/contributions/presentation/contribution_status_label.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_providers.dart';

/// One stokvel's page.
class StokvelDetailScreen extends ConsumerWidget {
  /// Creates the page for the stokvel with [stokvelId].
  const StokvelDetailScreen({required this.stokvelId, super.key});

  /// The stokvel to show.
  final String stokvelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(stokvelDetailViewProvider(stokvelId));
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (view.value) {
          StokvelContent(:final detail) => detail.name,
          StokvelNotFound() || null => 'Stokvel',
        }),
      ),
      body: AsyncBody(
        value: view,
        data: (v) => switch (v) {
          StokvelNotFound() => const Center(
            key: Key('not-found'),
            child: Text('Not found'),
          ),
          MemberView() => _Content(content: v, treasurer: false),
          TreasurerView() => _Content(content: v, treasurer: true),
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.content, required this.treasurer});

  final StokvelContent content;
  final bool treasurer;

  @override
  Widget build(BuildContext context) {
    final detail = content.detail;
    final cycle = detail.currentCycle;
    final dueOn = cycle?.endsOn;
    final names = {for (final m in detail.members) m.userId: m.fullName};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${formatRand(detail.contributionAmount)} per cycle · '
          '${detail.memberCount} members',
        ),
        const SizedBox(height: 16),
        if (cycle != null) ...[
          Text(
            'Cycle ${cycle.label}: ${formatRand(cycle.collected)} of '
            '${formatRand(cycle.due)} collected'
            '${dueOn == null ? '' : ' · due ${formatDate(dueOn)}'}',
          ),
          TextButton(
            onPressed: () =>
                CycleRoute(id: detail.id, cycleId: cycle.id).go(context),
            child: const Text('Open cycle'),
          ),
        ],
        if (treasurer)
          const Card(
            key: Key('treasurer-actions'),
            child: ListTile(
              title: Text('Treasurer actions'),
              subtitle: Text(
                'You run the money here: open and close cycles and pay out.',
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text('Contributions', style: Theme.of(context).textTheme.titleMedium),
        for (final c in content.contributions.items)
          ListTile(
            dense: true,
            title: Text(names[c.memberUserId] ?? 'A former member'),
            subtitle: Text(contributionStatusLabel(c.status)),
            trailing: Text(formatRand(c.amount)),
          ),
      ],
    );
  }
}
