import 'package:json_annotation/json_annotation.dart';
import 'package:rh_plus/models/user.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  final int id;
  final String name;
  final String taxId;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String status;
  @JsonKey(name: 'status_display')
  final String statusDisplay;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @JsonKey(name: 'approved_by')
  final int? approvedBy;
  @JsonKey(name: 'approved_by_email')
  final String? approvedByEmail;

  Company({
    required this.id,
    required this.name,
    required this.taxId,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    required this.status,
    required this.statusDisplay,
    required this.isActive,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.approvedByEmail,
  });

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  bool isPending() => status == 'PENDING';
  bool isApproved() => status == 'APPROVED';
  bool isRejected() => status == 'REJECTED';
}
