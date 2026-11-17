import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';

/// The signed-in person's activity feed, newest first.
abstract interface class ActivityRepository {
  /// One page of the feed. See `ContributionsRepository.page` for the paging
  /// contract.
  Future<PageOf<ActivityItem>> page({String? pageToken, int pageSize = 20});
}
