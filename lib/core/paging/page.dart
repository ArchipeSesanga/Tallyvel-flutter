import 'package:freezed_annotation/freezed_annotation.dart';

part 'page.freezed.dart';

/// One page of a list, plus how to ask for the next one.
///
/// The API ends a list with an empty `nextPageToken`. That detail stays in the
/// data layer: here a last page simply has no [nextPageToken], so the rest of
/// the app never compares a string to `""`.
@freezed
abstract class PageOf<T> with _$PageOf<T> {
  /// Creates a page.
  const factory PageOf({
    required List<T> items,

    /// Opaque; pass it back to get the next page. `null` means this is the
    /// last page.
    String? nextPageToken,
  }) = _PageOf<T>;

  const PageOf._();

  /// Whether another page can be asked for.
  bool get hasMore => nextPageToken != null;
}
