import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';
import 'package:tallyvel/features/cycles/domain/cycle.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';

part 'stokvel_detail_providers.g.dart';

/// One stokvel's page, as one of three cases. The role decides which case, so
/// a screen cannot show a treasurer action to a member by forgetting an `if`:
/// only [TreasurerView] means "the actions are allowed".
sealed class StokvelDetailView {
  const StokvelDetailView();
}

/// There is no such stokvel, or the person is not in it. The API answers both
/// the same way (404), and so does this.
final class StokvelNotFound extends StokvelDetailView {
  /// Creates the not-found case.
  const StokvelNotFound();
}

/// A stokvel the person is in: what every member sees.
sealed class StokvelContent extends StokvelDetailView {
  const StokvelContent({
    required this.detail,
    required this.cycles,
    required this.contributions,
  });

  /// The stokvel's page.
  final StokvelDetail detail;

  /// The stokvel's cycles.
  final List<Cycle> cycles;

  /// The first page of contributions.
  final PageOf<Contribution> contributions;
}

/// The person is an ordinary member here.
final class MemberView extends StokvelContent {
  /// Creates the member's view.
  const MemberView({
    required super.detail,
    required super.cycles,
    required super.contributions,
  });
}

/// The person is Treasurer or Chairperson here: the treasurer actions show.
final class TreasurerView extends StokvelContent {
  /// Creates the treasurer's view.
  const TreasurerView({
    required super.detail,
    required super.cycles,
    required super.contributions,
  });
}

/// One stokvel's page for the signed-in person.
@riverpod
Future<StokvelDetailView> stokvelDetailView(Ref ref, String stokvelId) async {
  final detail = await ref.watch(stokvelsRepositoryProvider).detail(stokvelId);
  if (detail == null) return const StokvelNotFound();

  final (memberships, cycles, contributions) = await (
    ref.watch(membershipsRepositoryProvider).mine(),
    ref.watch(cyclesRepositoryProvider).forStokvel(stokvelId),
    ref.watch(contributionsRepositoryProvider).page(stokvelId),
  ).wait;

  // The role is the one the API's membership says for THIS stokvel.
  final canRunMoney = memberships.any(
    (m) => m.stokvelId == stokvelId && m.role.canRunTreasurerActions,
  );
  return canRunMoney
      ? TreasurerView(
          detail: detail,
          cycles: cycles,
          contributions: contributions,
        )
      : MemberView(
          detail: detail,
          cycles: cycles,
          contributions: contributions,
        );
}
