import 'package:tallyvel/features/cycles/domain/cycle.dart';

/// A stokvel's collection periods.
abstract interface class CyclesRepository {
  /// Every cycle of [stokvelId], for a member of it.
  Future<List<Cycle>> forStokvel(String stokvelId);
}
