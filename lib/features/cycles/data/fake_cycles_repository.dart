import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/cycles/domain/cycle.dart';
import 'package:tallyvel/features/cycles/domain/cycles_repository.dart';

/// Answers from the seed world, as one signed-in user.
class FakeCyclesRepository implements CyclesRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeCyclesRepository(this._world, this._userId);

  final SeedWorld _world;
  final String _userId;

  @override
  Future<List<Cycle>> forStokvel(String stokvelId) async {
    final stokvel = _world.visibleTo(_userId, stokvelId);
    return stokvel == null ? const [] : [stokvel.cycle];
  }
}
