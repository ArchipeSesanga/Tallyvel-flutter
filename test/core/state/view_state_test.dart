import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyvel/core/state/view_state.dart';

ViewState<List<int>> _map(AsyncValue<List<int>> v) =>
    viewStateOf(v, isEmpty: (list) => list.isEmpty);

void main() {
  test('loading with nothing to show is Loading', () {
    expect(_map(const AsyncLoading()), isA<ViewLoading<List<int>>>());
  });

  test('an answer with something in it is Data', () {
    final state = _map(const AsyncData([1, 2]));

    expect(state, isA<ViewData<List<int>>>());
    final data = state as ViewData<List<int>>;
    expect(data.value, [1, 2]);
    expect(data.isRefreshing, isFalse);
    expect(data.refreshFailed, isFalse);
  });

  test(
    'an answer with nothing in it is Empty, not Data with an empty list',
    () {
      expect(_map(const AsyncData([])), isA<ViewEmpty<List<int>>>());
    },
  );

  test('an error with nothing older to show is Failure, with the error', () {
    final error = Exception('boom');
    final state = _map(AsyncError(error, StackTrace.empty));

    expect(state, isA<ViewFailure<List<int>>>());
    expect((state as ViewFailure<List<int>>).error, error);
  });

  group('a reload, seen through a real provider', () {
    late Completer<List<int>> reload;
    late FutureProvider<List<int>> numbers;
    late ProviderContainer container;

    setUp(() {
      reload = Completer<List<int>>();
      var call = 0;
      numbers = FutureProvider<List<int>>(
        (ref) => ++call == 1 ? Future.value([1, 2]) : reload.future,
      );
      container = ProviderContainer(retry: (_, _) => null);
      addTearDown(container.dispose);
      container.listen(numbers, (_, _) {});
    });

    test('keeps the old answer and says it is refreshing', () async {
      await container.read(numbers.future);

      container.invalidate(numbers);
      final state = _map(container.read(numbers)) as ViewData<List<int>>;

      expect(state.value, [1, 2]);
      expect(state.isRefreshing, isTrue);
      reload.complete([3]);
    });

    test('keeps the old answer and says the refresh failed', () async {
      await container.read(numbers.future);

      container
        ..invalidate(numbers)
        ..read(numbers); // the read starts the reload
      reload.completeError(Exception('x'));
      await pumpEventQueue();
      final state = _map(container.read(numbers)) as ViewData<List<int>>;

      expect(state.value, [1, 2]);
      expect(state.refreshFailed, isTrue);
      expect(state.isRefreshing, isFalse);
    });

    test('an empty answer stays Empty while it reloads', () async {
      reload.complete(const []);
      await container.read(numbers.future);
      container.invalidate(numbers);

      // The first answer was [1, 2]; the reload gives [] and is Empty.
      await container.read(numbers.future);
      expect(_map(container.read(numbers)), isA<ViewEmpty<List<int>>>());
    });
  });

  test('a switch over the four states needs no default', () {
    String label(ViewState<int> s) => switch (s) {
      ViewLoading() => 'loading',
      ViewEmpty() => 'empty',
      ViewFailure() => 'failure',
      ViewData() => 'data',
    };

    expect(label(const ViewLoading()), 'loading');
    expect(label(const ViewData(1)), 'data');
  });
}
