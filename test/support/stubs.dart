import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/activity/domain/activity_item.dart';
import 'package:tallyvel/features/activity/domain/activity_repository.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

/// A home repository that answers with whatever [onCards] returns, and counts
/// how often it was asked.
class StubHomeRepository implements HomeRepository {
  /// Creates a stub answering with [onCards].
  StubHomeRepository(this.onCards);

  /// Produces the answer for each call.
  final Future<List<HomeCard>> Function(int call) onCards;

  /// How many times [cards] was called.
  int calls = 0;

  @override
  Future<List<HomeCard>> cards() => onCards(++calls);
}

/// A stokvels repository that answers with [onDetail] and [onMine], and counts
/// how often the page was asked for, per stokvel id.
class StubStokvelsRepository implements StokvelsRepository {
  /// Creates a stub.
  StubStokvelsRepository({required this.onDetail, required this.onMine});

  /// Produces the answer for a stokvel's page.
  final Future<StokvelDetail?> Function(String id, int call) onDetail;

  /// Produces the answer for the list.
  final Future<List<Stokvel>> Function() onMine;

  /// How many times each stokvel's page was asked for.
  final Map<String, int> detailCalls = {};

  @override
  Future<List<Stokvel>> mine() => onMine();

  @override
  Future<StokvelDetail?> detail(String stokvelId) => onDetail(
    stokvelId,
    detailCalls.update(stokvelId, (n) => n + 1, ifAbsent: () => 1),
  );
}

/// An activity repository that answers with [onPage].
class StubActivityRepository implements ActivityRepository {
  /// Creates a stub answering with [onPage].
  StubActivityRepository(this.onPage);

  /// Produces the answer.
  final Future<PageOf<ActivityItem>> Function() onPage;

  @override
  Future<PageOf<ActivityItem>> page({String? pageToken, int pageSize = 20}) =>
      onPage();
}
