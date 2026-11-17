import 'package:tallyvel/features/memberships/domain/membership.dart';

/// Which stokvels the signed-in person is in, and as what.
abstract interface class MembershipsRepository {
  /// The signed-in person's memberships. Empty if they are in no stokvel.
  Future<List<Membership>> mine();
}
