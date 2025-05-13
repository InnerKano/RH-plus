class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final bool isStaff;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.isStaff,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isActive: json['is_active'] ?? false,
      isStaff: json['is_staff'] ?? false,
      roles: json['roles'] != null
          ? List<String>.from(json['roles'].map((role) => role['name']))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'is_staff': isStaff,
    };
  }

  String get fullName => '$firstName $lastName';
}
