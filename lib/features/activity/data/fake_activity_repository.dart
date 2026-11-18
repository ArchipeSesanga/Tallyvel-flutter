import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/paginate.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';
import 'package:tallyvel/features/activity/domain/activity_repository.dart';

/// Answers from the seed world, as one signed-in user.
class FakeActivityRepository implements ActivityRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeActivityRepository(
    this._world,
    this._userId, [
    this._latency = FakeLatency.none,
  ]);

  final SeedWorld _world;
  final String _userId;
  final FakeLatency _latency;

  @override
  Future<PageOf<ActivityItem>> page({
    String? pageToken,
    int pageSize = 20,
  }) async {
    await _latency.wait();
    return paginate(
      _world.activityOf(_userId),
      pageToken: pageToken,
      pageSize: pageSize,
    );
  }
}
