import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tallyvel/core/money/rand_format.dart';
import 'package:tallyvel/core/router/app_router.dart';
import 'package:tallyvel/core/widgets/async_body.dart';
import 'package:tallyvel/features/stokvels/presentation/stokvels_providers.dart';

/// The Stokvels tab: the stokvels the person is in.
class StokvelsScreen extends ConsumerWidget {
  /// Creates the stokvels screen.
  const StokvelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Stokvels')),
    body: AsyncBody(
      value: ref.watch(myStokvelsProvider),
      data: (stokvels) => stokvels.isEmpty
          ? const Center(child: Text('You are not in a stokvel yet.'))
          : ListView(
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
