import 'package:flutter/material.dart';
import 'package:tallyvel/core/state/view_state.dart';

/// Shows one of the four [ViewState]s: a spinner, [empty], a failure with a
/// retry, or [data].
///
/// Typed failures (offline, not allowed, rate limited...) arrive with the real
/// API; until then every failure reads the same.
class ViewStateBody<T> extends StatelessWidget {
  /// Creates a body for [state].
  const ViewStateBody({
    required this.state,
    required this.data,
    required this.empty,
    required this.onRetry,
    super.key,
  });

  /// The state being shown.
  final ViewState<T> state;

  /// Builds the screen for an answer.
  final Widget Function(T value) data;

  /// What to show when the answer is empty.
  final Widget empty;

  /// Called when the person taps "Try again".
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
    ViewLoading() => const Center(
      child: CircularProgressIndicator(key: Key('loading')),
    ),
    ViewEmpty() => empty,
    ViewFailure() => Center(
      key: const Key('failure'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("We couldn't load this."),
          const SizedBox(height: 12),
          FilledButton(
            key: const Key('retry'),
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
    ViewData(:final value, :final isRefreshing, :final refreshFailed) => Column(
      children: [
        if (isRefreshing) const LinearProgressIndicator(key: Key('refreshing')),
        if (refreshFailed)
          const MaterialBanner(
            key: Key('refresh-failed'),
            content: Text("Couldn't refresh. Showing what we had."),
            actions: [SizedBox.shrink()],
          ),
        Expanded(child: data(value)),
      ],
    ),
  };
}
