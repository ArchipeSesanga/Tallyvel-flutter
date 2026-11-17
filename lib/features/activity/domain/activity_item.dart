import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/features/activity/domain/activity_kind.dart';

part 'activity_item.freezed.dart';

/// One line in the signed-in person's activity feed.
@freezed
abstract class ActivityItem with _$ActivityItem {
  /// Creates an activity item.
  const factory ActivityItem({
    /// Unique and stable, but opaque: never parse it.
    required String id,
    required ActivityKind kind,
    required String stokvelId,
    required String stokvelName,

    /// An instant, in UTC.
    required DateTime occurredAt,

    /// `null` when no money is involved (someone joined).
    Cents? amount,

    /// Who it is about; `null` if they have since left the stokvel.
    String? personName,
  }) = _ActivityItem;
}
