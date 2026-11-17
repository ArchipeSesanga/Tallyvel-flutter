import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

/// Answers from the seed world, as one signed-in user.
class FakeStokvelsRepository implements StokvelsRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeStokvelsRepository(
    this._world,
    this._userId, [
    this._latency = FakeLatency.none,
  ]);

  final SeedWorld _world;
  final String _userId;
  final FakeLatency _latency;

  @override
  Future<List<Stokvel>> mine() async {
    await _latency.wait();
    return [for (final s in _world.stokvelsOf(_userId)) _world.summary(s)];
  }

  @override
  Future<StokvelDetail?> detail(String stokvelId) async {
    await _latency.wait(stokvelId);
    final stokvel = _world.visibleTo(_userId, stokvelId);
    return stokvel == null ? null : _world.detail(stokvel);
  }
}
