import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';

part 'home_providers.g.dart';

/// What the home screen shows, as a closed set of cases the screen must
/// handle one by one.
sealed class HomeView {
  const HomeView();
}

/// The person is in no stokvel yet: show the empty state, not a blank list.
class HomeEmpty extends HomeView {
  /// Creates the empty state.
  const HomeEmpty();
}

/// The person's stokvels, one card each.
class HomeLoaded extends HomeView {
  /// Creates the loaded state.
  const HomeLoaded(this.cards);

  /// One card per stokvel.
  final List<HomeCard> cards;
}

/// The home screen's state. Loading and failure come from [AsyncValue]; this
/// only says what a *successful* answer means.
@riverpod
Future<HomeView> homeView(Ref ref) async {
  final cards = await ref.watch(homeRepositoryProvider).cards();
  return cards.isEmpty ? const HomeEmpty() : HomeLoaded(cards);
}
