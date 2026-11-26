import 'package:dio/dio.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/core/network/json_reader.dart';
import 'package:tallyvel/core/paging/page.dart';
import 'package:tallyvel/features/contributions/data/contribution_status_mapper.dart';
import 'package:tallyvel/features/contributions/domain/contribution.dart';
import 'package:tallyvel/features/contributions/domain/contributions_repository.dart';

/// A stokvel's contributions from
/// `GET /api/v1/stokvels/{id}/contributions`, one page at a time.
class ApiContributionsRepository implements ContributionsRepository {
  /// Creates a repository that asks through [_dio].
  const ApiContributionsRepository(this._dio);

  final Dio _dio;

  @override
  Future<PageOf<Contribution>> page(
    String stokvelId, {
    String? pageToken,
    int pageSize = 20,
  }) async {
    final response = await guardApi(
      () => _dio.get<Object?>(
        '/api/v1/stokvels/$stokvelId/contributions',
        queryParameters: {'pageSize': pageSize, 'pageToken': ?pageToken},
      ),
    );
    final body = asJson(response.data);
    // The API ends a list with an empty token, never null (README, contract
    // notes, section 1). That marker stays in this file.
    final next = readString(body, 'nextPageToken');
    return PageOf(
      items: [
        for (final c in asJsonList(body['items']))
          Contribution(
            id: readString(c, 'id'),
            stokvelId: readString(c, 'stokvelId'),
            memberUserId: readString(c, 'memberUserId'),
            cycleLabel: readString(c, 'cycle'),
            amount: readCents(c, 'amountCents'),
            status: contributionStatusFromApi(readStringOrNull(c, 'status')),
            recordedAt: readDateTime(c, 'recordedAt'),
            hasProof: c['hasProof'] == true,
            canDownloadProof: c['canDownloadProof'] == true,
          ),
      ],
      nextPageToken: next.isEmpty ? null : next,
    );
  }
}
