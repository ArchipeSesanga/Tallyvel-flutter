import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';

part 'home_providers.g.dart';

/// The home screen's cards.
///
/// An `AsyncNotifier`, not a plain future, because the person can pull to
/// refresh: [refresh] reloads while the old cards stay on screen.
@riverpod
class Home extends _$Home {
  @override
  Future<List<HomeCard>> build() => ref.watch(homeRepositoryProvider).cards();

  /// Reloads the cards. Riverpod keeps the previous cards in [state] while
  /// the rebuild runs, and after it if it fails, so the screen never goes
  /// blank. Never throws: a failed refresh is in [state] for the screen to
  /// show next to the old cards.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future.then((_) {}, onError: (Object _) {});
  }
}

/// Maps the home screen's [AsyncValue] to its four states. A person in no
/// stokvel is [ViewEmpty], not a list with nothing in it.
ViewState<List<HomeCard>> homeViewStateOf(AsyncValue<List<HomeCard>> value) =>
    viewStateOf(value, isEmpty: (cards) => cards.isEmpty);
