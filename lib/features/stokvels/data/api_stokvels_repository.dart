import 'package:dio/dio.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/core/network/json_reader.dart';
import 'package:tallyvel/features/cycles/data/cycle_status_mapper.dart';
import 'package:tallyvel/features/memberships/data/member_role_mapper.dart';
import 'package:tallyvel/features/stokvels/data/contribution_frequency_mapper.dart';
import 'package:tallyvel/features/stokvels/domain/stokvel.dart';
import 'package:tallyvel/features/stokvels/domain/stokvels_repository.dart';

/// Stokvels from `GET /api/v1/stokvels` and `GET /api/v1/stokvels/{id}`.
class ApiStokvelsRepository implements StokvelsRepository {
  /// Creates a repository that asks through [_dio].
  const ApiStokvelsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Stokvel>> mine() async {
    final response = await guardApi(
      () => _dio.get<Object?>('/api/v1/stokvels'),
    );
    return [for (final item in asJsonList(response.data)) _summary(item)];
  }

  @override
  Future<StokvelDetail?> detail(String stokvelId) async {
    try {
      final response = await guardApi(
        () => _dio.get<Object?>('/api/v1/stokvels/$stokvelId'),
      );
      return _detail(asJson(response.data));
    } on NotFoundFailure {
      // Missing, or not the person's to see: the API sends the same 404.
      return null;
    }
  }
}

Stokvel _summary(Json json) => Stokvel(
  id: readString(json, 'id'),
  name: readString(json, 'name'),
  contributionAmount: readCents(json, 'contributionAmountCents'),
  frequency: contributionFrequencyFromApi(readStringOrNull(json, 'cycle')),
  createdAt: readDateTime(json, 'createdAt'),
  memberCount: asJsonList(json['members']).length,
);

StokvelDetail _detail(Json json) {
  final cycle = readJsonOrNull(json, 'currentCycle');
  return StokvelDetail(
    id: readString(json, 'id'),
    name: readString(json, 'name'),
    contributionAmount: readCents(json, 'contributionAmountCents'),
    frequency: contributionFrequencyFromApi(readStringOrNull(json, 'cycle')),
    createdAt: readDateTime(json, 'createdAt'),
    members: [
      for (final m in asJsonList(json['members']))
        StokvelMember(
          userId: readString(m, 'userId'),
          role: memberRoleFromApi(readStringOrNull(m, 'role')),
          joinedAt: readDateTime(m, 'joinedAt'),
          fullName: readStringOrNull(m, 'fullName'),
        ),
    ],
    memberCount: readInt(json, 'memberCount'),
    currentCycle: cycle == null
        ? null
        : CycleProgress(
            id: readString(cycle, 'id'),
            label: readString(cycle, 'label'),
            status: cycleStatusFromApi(readStringOrNull(cycle, 'status')),
            collected: readCents(cycle, 'collectedCents'),
            due: readCents(cycle, 'dueCents'),
            endsOn: readDateOrNull(cycle, 'endsOn'),
          ),
    rules: readStringOrNull(json, 'rules'),
  );
}
