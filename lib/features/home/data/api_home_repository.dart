import 'package:dio/dio.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/core/network/json_reader.dart';
import 'package:tallyvel/features/cycles/data/cycle_status_mapper.dart';
import 'package:tallyvel/features/home/domain/home_card.dart';
import 'package:tallyvel/features/home/domain/home_repository.dart';
import 'package:tallyvel/features/memberships/data/member_role_mapper.dart';

/// The home screen from `GET /api/v1/me/home`.
class ApiHomeRepository implements HomeRepository {
  /// Creates a repository that asks through [_dio].
  const ApiHomeRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<HomeCard>> cards() async {
    final response = await guardApi(() => _dio.get<Object?>('/api/v1/me/home'));
    final stokvels = switch (asJson(response.data)['stokvels']) {
      final List<Object?> list => list,
      _ => throw const UnexpectedFailure(),
    };
    return [for (final item in stokvels) homeCardFromJson(asJson(item))];
  }
}

/// One `HomeStokvelCard`.
HomeCard homeCardFromJson(Json json) {
  final cycle = readJsonOrNull(json, 'currentCycle');
  return HomeCard(
    stokvelId: readString(json, 'stokvelId'),
    name: readString(json, 'name'),
    role: memberRoleFromApi(readStringOrNull(json, 'role')),
    paidThisCycle: readCents(json, 'paidThisCycleCents'),
    owedThisCycle: readCents(json, 'owedThisCycleCents'),
    currentCycle: cycle == null
        ? null
        : HomeCycle(
            id: readString(cycle, 'id'),
            label: readString(cycle, 'label'),
            status: cycleStatusFromApi(readStringOrNull(cycle, 'status')),
            startsOn: readDateOrNull(cycle, 'startsOn'),
            endsOn: readDateOrNull(cycle, 'endsOn'),
          ),
    nextPayoutDate: readDateOrNull(json, 'nextPayoutDate'),
  );
}
