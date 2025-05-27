import 'package:json_annotation/json_annotation.dart';
import 'package:rh_plus/models/user.dart';
import 'package:rh_plus/models/company.dart';
import 'package:rh_plus/models/role.dart';

part 'company_user.g.dart';

@JsonSerializable()
class CompanyUser {
  final int id;
  @JsonKey(name: 'user')
  final int userId;
  @JsonKey(name: 'user_email')
  final String userEmail;
  @JsonKey(name: 'user_name')
  final String userName;
  @JsonKey(name: 'company')
  final int companyId;
  @JsonKey(name: 'company_name')
  final String companyName;
  final List<int> roles;
  @JsonKey(name: 'roles_display')
  final List<String> rolesDisplay;
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  final String status;
  @JsonKey(name: 'status_display')
  final String statusDisplay;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @JsonKey(name: 'approved_by')
  final int? approvedBy;
  @JsonKey(name: 'approved_by_email')
  final String? approvedByEmail;

  CompanyUser({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.companyId,
    required this.companyName,
    required this.roles,
    required this.rolesDisplay,
    required this.isPrimary,
    required this.status,
    required this.statusDisplay,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.approvedByEmail,
  });

  factory CompanyUser.fromJson(Map<String, dynamic> json) => _$CompanyUserFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyUserToJson(this);

  bool isPending() => status == 'PENDING';
  bool isApproved() => status == 'APPROVED';
  bool isRejected() => status == 'REJECTED';
  
  bool hasRole(String roleName) => rolesDisplay.contains(roleName);
}
