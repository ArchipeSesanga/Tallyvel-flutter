import 'package:tallyvel/features/memberships/domain/member_role.dart';

/// Reads the API's role name. The API spells them exactly `Member`,
/// `Treasurer` and `Chairperson` (README, Contract notes, section 3); anything
/// else, including a different case, a missing value or a role added later,
/// is [MemberRole.unknown] and never a crash.
MemberRole memberRoleFromApi(String? value) => switch (value) {
  'Member' => MemberRole.member,
  'Treasurer' => MemberRole.treasurer,
  'Chairperson' => MemberRole.chairperson,
  _ => MemberRole.unknown,
};
