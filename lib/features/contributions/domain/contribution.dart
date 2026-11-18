import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/core/money/cents.dart';
import 'package:tallyvel/features/contributions/domain/contribution_status.dart';

part 'contribution.freezed.dart';

/// One member's payment into one cycle.
@freezed
abstract class Contribution with _$Contribution {
  /// Creates a contribution.
  const factory Contribution({
    required String id,
    required String stokvelId,
    required String memberUserId,

    /// The label of the cycle it belongs to, for example `2026-11`.
    required String cycleLabel,
    required Cents amount,
    required ContributionStatus status,

    /// An instant, in UTC.
    required DateTime recordedAt,

    /// Whether a proof of payment is attached.
    required bool hasProof,

    /// Whether the signed-in person may download that proof.
    required bool canDownloadProof,
  }) = _Contribution;
}
