import 'package:json_annotation/json_annotation.dart';
import 'package:rh_plus/models/role.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_staff')
  final bool isStaff;
  final List<Role> roles;
  @JsonKey(includeFromJson: false, includeToJson: false)
  int? activeCompanyId;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.isStaff,
    required this.roles,
    this.activeCompanyId,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  String get fullName => '$firstName $lastName'.trim();
  
  bool hasRole(String roleName) {
    return roles.any((role) => role.name == roleName);
  }
  
  bool isSuperAdmin() => isStaff;
}
