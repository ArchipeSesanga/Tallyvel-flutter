import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

/// The stokvels the signed-in person belongs to.
abstract interface class StokvelsRepository {
  /// The person's stokvels. Empty if they are in none.
  Future<List<Stokvel>> mine();

  /// One stokvel's page, or `null` if there is no such stokvel *or the person
  /// is not in it*. The two are the same answer on purpose: the API does not
  /// confirm that a stokvel exists to someone outside it.
  Future<StokvelDetail?> detail(String stokvelId);
}
