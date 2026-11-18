import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a screen shows, as four cases it must handle one by one.
///
/// `AsyncValue` says whether data is loading, failed or arrived. A screen needs
/// one more fact that `AsyncValue` cannot give: whether data that *arrived* is
/// empty. [viewStateOf] turns the one into the other, so every list screen has
/// the same four states and a `switch` over them needs no default.
sealed class ViewState<T> {
  const ViewState();
}

/// Nothing has arrived yet. Show a spinner.
final class ViewLoading<T> extends ViewState<T> {
  /// Creates the loading state.
  const ViewLoading();
}

/// An answer arrived, and there is nothing in it: no stokvels, no activity, or
/// (for a page about one thing) no such thing.
final class ViewEmpty<T> extends ViewState<T> {
  /// Creates the empty state.
  const ViewEmpty();
}

/// The request failed and there is no older answer to show. Offer a retry.
final class ViewFailure<T> extends ViewState<T> {
  /// Creates the failure state for [error].
  const ViewFailure(this.error);

  /// What went wrong.
  final Object error;
}

/// An answer to show.
final class ViewData<T> extends ViewState<T> {
  /// Creates the data state.
  const ViewData(
    this.value, {
    this.isRefreshing = false,
    this.refreshFailed = false,
  });

  /// The answer.
  final T value;

  /// Whether a newer answer is being fetched. [value] is still the old one:
  /// a pull-to-refresh must not blank the screen.
  final bool isRefreshing;

  /// Whether the last refresh failed. [value] is the old answer, still shown.
  final bool refreshFailed;
}

/// Turns [value] into one of the four states. [isEmpty] says whether an answer
/// that arrived counts as "nothing here".
ViewState<T> viewStateOf<T>(
  AsyncValue<T> value, {
  required bool Function(T answer) isEmpty,
}) {
  // `value.value` is the current answer or, while reloading or after a failed
  // reload, the previous one.
  if (value.hasValue) {
    final answer = value.requireValue;
    if (isEmpty(answer)) return ViewEmpty<T>();
    return ViewData<T>(
      answer,
      isRefreshing: value.isLoading,
      refreshFailed: value.hasError,
    );
  }
  final error = value.error;
  if (error != null) return ViewFailure<T>(error);
  return ViewLoading<T>();
}
