import 'package:dio/dio.dart';
import 'package:tallyvel/core/network/failure_mapper.dart';
import 'package:tallyvel/core/network/json_reader.dart';
import 'package:tallyvel/features/cycles/data/cycle_status_mapper.dart';
import 'package:tallyvel/features/cycles/domain/cycle.dart';
import 'package:tallyvel/features/cycles/domain/cycles_repository.dart';

/// A stokvel's cycles from `GET /api/v1/stokvels/{id}/cycles`.
class ApiCyclesRepository implements CyclesRepository {
  /// Creates a repository that asks through [_dio].
  const ApiCyclesRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Cycle>> forStokvel(String stokvelId) async {
    final response = await guardApi(
      () => _dio.get<Object?>('/api/v1/stokvels/$stokvelId/cycles'),
    );
    return [
      for (final c in asJsonList(response.data))
        Cycle(
          id: readString(c, 'id'),
          stokvelId: readString(c, 'stokvelId'),
          label: readString(c, 'label'),
          status: cycleStatusFromApi(readStringOrNull(c, 'status')),
        ),
    ];
  }
}
