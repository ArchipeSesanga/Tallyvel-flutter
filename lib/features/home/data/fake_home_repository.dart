import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';

/// Answers the home screen from the seed world, as one signed-in user.
class FakeHomeRepository implements HomeRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeHomeRepository(this._world, this._userId);

  final SeedWorld _world;
  final String _userId;

  @override
  Future<List<HomeCard>> cards() async => [
    for (final s in _world.stokvelsOf(_userId)) _world.cardFor(_userId, s),
  ];
}
