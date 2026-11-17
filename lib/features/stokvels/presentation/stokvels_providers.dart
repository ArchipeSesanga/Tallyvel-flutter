import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

part 'stokvels_providers.g.dart';

/// The person's stokvels, for the Stokvels tab and the stokvel picker.
@riverpod
Future<List<Stokvel>> myStokvels(Ref ref) =>
    ref.watch(stokvelsRepositoryProvider).mine();

/// Maps the list's [AsyncValue] to its four states.
ViewState<List<Stokvel>> myStokvelsViewStateOf(
  AsyncValue<List<Stokvel>> value,
) => viewStateOf(value, isEmpty: (stokvels) => stokvels.isEmpty);
