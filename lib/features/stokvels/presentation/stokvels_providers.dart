import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

part 'stokvels_providers.g.dart';

/// The person's stokvels, for the Stokvels tab.
@riverpod
Future<List<Stokvel>> myStokvels(Ref ref) =>
    ref.watch(stokvelsRepositoryProvider).mine();
