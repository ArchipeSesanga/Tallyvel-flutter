import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tallyvel/app/composition_root.dart';
import 'package:tallyvel/core/state/view_state.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';
import 'package:tallyvel/features/stokvel_detail/domain/stokvel_page.dart';

part 'stokvel_detail_providers.g.dart';

/// One stokvel's page for the signed-in person, or `null` if there is no such
/// stokvel *or the person is not in it* (the API answers both with 404).
///
/// A family: one state per [stokvelId]. Each id is fetched once, however many
/// widgets listen, and disposed when the last one stops.
@riverpod
Future<StokvelPage?> stokvelPage(Ref ref, String stokvelId) async {
  final detail = await ref.watch(stokvelsRepositoryProvider).detail(stokvelId);
  if (detail == null) return null;

  final (memberships, cycles, contributions) = await (
    ref.watch(membershipsRepositoryProvider).mine(),
    ref.watch(cyclesRepositoryProvider).forStokvel(stokvelId),
    ref.watch(contributionsRepositoryProvider).page(stokvelId),
  ).wait;

  // The role is the one the membership says for THIS stokvel. No membership
  // for a stokvel whose page we were given is inconsistent: grant nothing.
  var role = MemberRole.unknown;
  for (final m in memberships) {
    if (m.stokvelId == stokvelId) role = m.role;
  }

  final me = ref.watch(signedInUserIdProvider);
  final cycleLabel = detail.currentCycle?.label;
  final mine = cycleLabel == null
      ? null
      : contributions.items
            .where((c) => c.memberUserId == me && c.cycleLabel == cycleLabel)
            .map((c) => c.status)
            .firstOrNull;

  return StokvelPage(
    detail: detail,
    cycles: cycles,
    contributions: contributions,
    role: role,
    myContribution: mine,
  );
}

/// Maps the page's [AsyncValue] to its four states. "No such stokvel" and
/// "not a member" are both [ViewEmpty].
ViewState<StokvelPage?> stokvelPageViewStateOf(
  AsyncValue<StokvelPage?> value,
) => viewStateOf(value, isEmpty: (page) => page == null);
