import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/core/time/format_date.dart';
import 'package:tallyvel/core/widgets/view_state_body.dart';
import 'package:tallyvel/features/contributions/presentation/contribution_status_label.dart';
import 'package:tallyvel/features/cycles/presentation/cycle_status_label.dart';
import 'package:tallyvel/features/memberships/presentation/role_label.dart';
import 'package:tallyvel/features/stokvel_detail/domain/stokvel_page.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_action_label.dart';
import 'package:tallyvel/features/stokvel_detail/presentation/stokvel_detail_providers.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_providers.dart';

/// One stokvel's page, with a picker in the app bar to switch to another of
/// the person's stokvels without going back.
class StokvelDetailScreen extends ConsumerStatefulWidget {
  /// Creates the page for the stokvel with [stokvelId].
  const StokvelDetailScreen({required this.stokvelId, super.key});

  /// The stokvel to show first.
  final String stokvelId;

  @override
  ConsumerState<StokvelDetailScreen> createState() =>
      _StokvelDetailScreenState();
}

class _StokvelDetailScreenState extends ConsumerState<StokvelDetailScreen> {
  late String _stokvelId = widget.stokvelId;

  @override
  void didUpdateWidget(StokvelDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new id from the route replaces whatever the picker chose.
    if (oldWidget.stokvelId != widget.stokvelId) _stokvelId = widget.stokvelId;
  }

  @override
  Widget build(BuildContext context) {
    // The id in the provider call is the whole point of the picker: choosing
    // another stokvel watches another family member, with its own state.
    final async = ref.watch(stokvelPageProvider(_stokvelId));
    final state = stokvelPageViewStateOf(async);
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (state) {
          ViewData(:final value) when value != null => value.detail.name,
          ViewData() ||
          ViewLoading() ||
          ViewEmpty() ||
          ViewFailure() => 'Stokvel',
        }),
        actions: [
          _StokvelPicker(
            selectedId: _stokvelId,
            onSelected: (id) => setState(() => _stokvelId = id),
          ),
        ],
      ),
      body: ViewStateBody(
        state: state,
        onRetry: () => ref.invalidate(stokvelPageProvider(_stokvelId)),
        empty: const Center(key: Key('not-found'), child: Text('Not found')),
        data: (page) => page == null
            ? const Center(key: Key('not-found'), child: Text('Not found'))
            : _Content(page: page),
      ),
    );
  }
}

class _StokvelPicker extends ConsumerWidget {
  const _StokvelPicker({required this.selectedId, required this.onSelected});

  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stokvels = ref.watch(myStokvelsProvider).value ?? const [];
    return PopupMenuButton<String>(
      key: const Key('stokvel-picker'),
      tooltip: 'Switch stokvel',
      icon: const Icon(Icons.swap_horiz),
      enabled: stokvels.length > 1,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final s in stokvels)
          CheckedPopupMenuItem(
            key: Key('pick-${s.id}'),
            value: s.id,
            checked: s.id == selectedId,
            child: Text(s.name),
          ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.page});

  final StokvelPage page;

  @override
  Widget build(BuildContext context) {
    final detail = page.detail;
    final cycle = detail.currentCycle;
    final dueOn = cycle?.endsOn;
    final names = {for (final m in detail.members) m.userId: m.fullName};
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '${formatRand(detail.contributionAmount)} per cycle · '
          '${detail.memberCount} members · you are '
          '${roleLabel(page.role).toLowerCase()}',
        ),
        const SizedBox(height: 16),
        if (cycle != null) ...[
          Text(
            'Cycle ${cycle.label} (${cycleStatusLabel(cycle.status)}): '
            '${formatRand(cycle.collected)} of ${formatRand(cycle.due)} '
            'collected${dueOn == null ? '' : ' · due ${formatDate(dueOn)}'}',
          ),
          TextButton(
            onPressed: () =>
                CycleRoute(id: detail.id, cycleId: cycle.id).go(context),
            child: const Text('Open cycle'),
          ),
        ],
        if (page.actions.isNotEmpty)
          Card(
            key: const Key('actions'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can do here',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  for (final action in page.actions)
                    Text(
                      '• ${stokvelActionLabel(action)}',
                      key: Key('action-${action.name}'),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text('Contributions', style: Theme.of(context).textTheme.titleMedium),
        for (final c in page.contributions.items)
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
