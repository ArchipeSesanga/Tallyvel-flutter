import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';

part 'activity_providers.g.dart';

/// The first page of the person's activity feed.
@riverpod
Future<PageOf<ActivityItem>> activityFeed(Ref ref) =>
    ref.watch(activityRepositoryProvider).page();

/// Maps the feed's [AsyncValue] to its four states.
ViewState<PageOf<ActivityItem>> activityViewStateOf(
  AsyncValue<PageOf<ActivityItem>> value,
) => viewStateOf(value, isEmpty: (page) => page.items.isEmpty);
