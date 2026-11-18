import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';

/// Answers the home screen from the seed world, as one signed-in user.
class FakeHomeRepository implements HomeRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeHomeRepository(
    this._world,
    this._userId, [
    this._latency = FakeLatency.none,
  ]);

  final SeedWorld _world;
  final String _userId;
  final FakeLatency _latency;

  @override
  Future<List<HomeCard>> cards() async {
    await _latency.wait();
    return [
      for (final s in _world.stokvelsOf(_userId)) _world.cardFor(_userId, s),
    ];
  }
}
