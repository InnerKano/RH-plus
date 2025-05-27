class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String roleDisplay;
  final String? department;
  final String? manager;
  final String? managerName;
  final bool isActive;
  final DateTime dateJoined;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.roleDisplay,
    this.department,
    this.manager,
    this.managerName,
    required this.isActive,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? 'USER',
      roleDisplay: json['role_display'] ?? 'Usuario Básico',
      department: json['department'],
      manager: json['manager']?.toString(),
      managerName: json['manager_name'],
      isActive: json['is_active'] ?? true,
      dateJoined: DateTime.parse(json['date_joined'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'role': role,
      'role_display': roleDisplay,
      'department': department,
      'manager': manager,
      'manager_name': managerName,
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();
}

class UserPermissions {
  final String role;
  final String roleDisplay;
  final List<String> accessibleModules;
  final bool canManageUsers;
  final List<String> manageableRoles;

  UserPermissions({
    required this.role,
    required this.roleDisplay,
    required this.accessibleModules,
    required this.canManageUsers,
    required this.manageableRoles,
  });

  factory UserPermissions.fromJson(Map<String, dynamic> json) {
    return UserPermissions(
      role: json['role'] ?? 'USER',
      roleDisplay: json['role_display'] ?? 'Usuario Básico',
      accessibleModules: List<String>.from(json['accessible_modules'] ?? []),
      canManageUsers: json['can_manage_users'] ?? false,
      manageableRoles: List<String>.from(json['manageable_roles'] ?? []),
    );
  }

  bool canAccessModule(String module) {
    return accessibleModules.contains(module);
  }
}
