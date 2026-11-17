import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';

/// A stokvel's contributions, newest first.
abstract interface class ContributionsRepository {
  /// One page of [stokvelId]'s contributions. Pass the previous page's
  /// [PageOf.nextPageToken] as [pageToken] to continue; omit it for the first
  /// page.
  Future<PageOf<Contribution>> page(
    String stokvelId, {
    String? pageToken,
    int pageSize = 20,
  });
}
