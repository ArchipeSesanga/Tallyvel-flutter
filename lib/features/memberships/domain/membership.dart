import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tallyvel/features/memberships/domain/member_role.dart';

part 'membership.freezed.dart';

/// The signed-in person's place in one stokvel.
@freezed
abstract class Membership with _$Membership {
  /// Creates a membership.
  const factory Membership({
    required String stokvelId,
    required MemberRole role,
  }) = _Membership;
}
