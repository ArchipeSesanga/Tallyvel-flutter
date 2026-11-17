import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/widgets/async_body.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';
import 'package:tallyvel/features/activity/domain/activity_kind.dart';
import 'package:tallyvel/features/activity/presentation/activity_providers.dart';

/// The Activity tab: what happened in the person's stokvels.
class ActivityScreen extends ConsumerWidget {
  /// Creates the activity screen.
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Activity')),
    body: AsyncBody(
      value: ref.watch(activityFeedProvider),
      data: (page) => page.items.isEmpty
          ? const Center(child: Text('Nothing has happened yet.'))
          : ListView(
              children: [
                for (final item in page.items)
                  ListTile(
                    key: Key('activity-${item.id}'),
                    title: Text(_sentence(item)),
                    subtitle: Text(item.stokvelName),
                  ),
              ],
            ),
    ),
  );
}

String _sentence(ActivityItem item) {
  final who = item.personName ?? 'A former member';
  final amount = item.amount == null ? '' : ' ${formatRand(item.amount!)}';
  return switch (item.kind) {
    ActivityKind.contributionRecorded => '$who paid$amount',
    ActivityKind.payoutMade => '$who was paid out$amount',
    ActivityKind.memberJoined => '$who joined',
    ActivityKind.unknown => 'Something happened',
  };
}
