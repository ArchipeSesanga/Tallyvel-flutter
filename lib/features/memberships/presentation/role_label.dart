import 'package:tallyvel/features/memberships/domain/member_role.dart';

/// What to call [role] on screen.
String roleLabel(MemberRole role) => switch (role) {
  MemberRole.member => 'Member',
  MemberRole.treasurer => 'Treasurer',
  MemberRole.chairperson => 'Chairperson',
  MemberRole.unknown => 'Member',
};
