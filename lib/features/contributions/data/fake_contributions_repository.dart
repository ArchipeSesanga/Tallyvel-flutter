import 'package:tallyvel/core/fakes/fake_latency.dart';
import 'package:tallyvel/core/fakes/paginate.dart';
import 'package:tallyvel/core/fakes/seed_world.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';
import 'package:tallyvel/features/contributions/domain/contributions_repository.dart';

/// Answers from the seed world, as one signed-in user.
class FakeContributionsRepository implements ContributionsRepository {
  /// Creates a repository that answers from [_world] as user [_userId].
  const FakeContributionsRepository(
    this._world,
    this._userId, [
    this._latency = FakeLatency.none,
  ]);

  final SeedWorld _world;
  final String _userId;
  final FakeLatency _latency;

  @override
  Future<PageOf<Contribution>> page(
    String stokvelId, {
    String? pageToken,
    int pageSize = 20,
  }) async {
    await _latency.wait(stokvelId);
    // Outside the stokvel the API answers 404; the screens only ask after the
    // stokvel's own page succeeded, so an empty page is enough here.
    if (_world.visibleTo(_userId, stokvelId) == null) {
      return const PageOf(items: []);
    }
    return paginate(
      [
        for (final c in _world.contributions)
          if (c.stokvelId == stokvelId) c,
      ],
      pageToken: pageToken,
      pageSize: pageSize,
    );
  }
}
