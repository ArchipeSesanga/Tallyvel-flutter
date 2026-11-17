import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows a spinner while [value] loads, a plain message if it failed, and
/// [data] once it has a value.
///
/// Typed failures (not found, forbidden, offline...) arrive with the real API;
/// until then every failure reads the same.
class AsyncBody<T> extends StatelessWidget {
  /// Creates a body for [value].
  const AsyncBody({required this.value, required this.data, super.key});

  /// The state being shown.
  final AsyncValue<T> value;

  /// Builds the screen once there is a value.
  final Widget Function(T value) data;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => const Center(child: Text('Something went wrong')),
  );
}
