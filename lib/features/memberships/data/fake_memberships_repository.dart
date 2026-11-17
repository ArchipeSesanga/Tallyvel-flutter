import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/features/memberships/domain/membership.dart';
import 'package:tallyvel/features/memberships/domain/memberships_repository.dart';

/// Answers from the seed world, as one signed-in user.
class FakeMembershipsRepository implements MembershipsRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeMembershipsRepository(this._world, this._userId);

  final SeedWorld _world;
  final String _userId;

  @override
  Future<List<Membership>> mine() async => _world.membershipsOf(_userId);
}
