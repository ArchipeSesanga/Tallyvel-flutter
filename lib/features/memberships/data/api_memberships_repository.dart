import 'package:dio/dio.dart';
import 'package:tallyvel/core/failures/failure.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/core/network/json_reader.dart';
import 'package:tallyvel/features/memberships/data/member_role_mapper.dart';
import 'package:tallyvel/features/memberships/domain/membership.dart';
import 'package:tallyvel/features/memberships/domain/memberships_repository.dart';

/// What the person is in each stokvel. The API has no memberships endpoint;
/// `GET /api/v1/me/home` has one card per stokvel with the caller's role.
class ApiMembershipsRepository implements MembershipsRepository {
  /// Creates a repository that asks through [_dio].
  const ApiMembershipsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Membership>> mine() async {
    final response = await guardApi(() => _dio.get<Object?>('/api/v1/me/home'));
    final cards = switch (asJson(response.data)['stokvels']) {
      final List<Object?> list => list,
      _ => throw const UnexpectedFailure(),
    };
    return [
      for (final card in cards)
        Membership(
          stokvelId: readString(asJson(card), 'stokvelId'),
          role: memberRoleFromApi(readStringOrNull(asJson(card), 'role')),
        ),
    ];
  }
}
