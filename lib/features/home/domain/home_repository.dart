import 'package:tallyvel/features/home/domain/home_card.dart';

/// What the home screen shows.
abstract interface class HomeRepository {
  /// One card per stokvel the signed-in person is in. Empty if they are in
  /// none.
  Future<List<HomeCard>> cards();
}
