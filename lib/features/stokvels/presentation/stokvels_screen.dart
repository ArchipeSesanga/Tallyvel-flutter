import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/widgets/view_state_body.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_providers.dart';

/// The Stokvels tab: the stokvels the person is in.
class StokvelsScreen extends ConsumerWidget {
  /// Creates the stokvels screen.
  const StokvelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Stokvels')),
    body: ViewStateBody(
      state: myStokvelsViewStateOf(ref.watch(myStokvelsProvider)),
      onRetry: () => ref.invalidate(myStokvelsProvider),
      empty: const Center(
        key: Key('stokvels-empty'),
        child: Text("You're not in a stokvel yet."),
      ),
      data: (stokvels) => ListView(
        children: [
          for (final s in stokvels)
            ListTile(
              key: Key('stokvel-${s.id}'),
              title: Text(s.name),
              subtitle: Text(
                '${formatRand(s.contributionAmount)} · '
                '${s.memberCount} members',
              ),
              onTap: () => StokvelRoute(id: s.id).go(context),
            ),
        ],
      ),
    ),
  );
}
