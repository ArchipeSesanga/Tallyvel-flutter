import 'package:tallyvel/core/paging/page.dart';

/// Cuts [all] into the page that [pageToken] asks for, the way the API does:
/// a size of 0 means 20, anything above 100 means 100, and the last page has
/// no next token.
///
/// The token is only an offset here. A real token is opaque, so callers must
/// not read it; they just hand it back.
PageOf<T> paginate<T>(List<T> all, {String? pageToken, int pageSize = 20}) {
  final size = pageSize <= 0 ? 20 : (pageSize > 100 ? 100 : pageSize);
  final start = pageToken == null ? 0 : int.parse(pageToken);
  final end = start + size;
  return PageOf(
    items: all.sublist(start.clamp(0, all.length), end.clamp(0, all.length)),
    nextPageToken: end < all.length ? '$end' : null,
  );
}
