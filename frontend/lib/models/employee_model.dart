class EmployeeModel {
  final int id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String email;
  final String phone;
  final String address;
  final String status;
  final String position;
  final String department;
  final String hireDate;
  final String? terminationDate;

  EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.position,
    required this.department,
    required this.hireDate,
    this.terminationDate,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      employeeId: json['employee_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      status: json['status'],
      position: json['position'],
      department: json['department'],
      hireDate: json['hire_date'],
      terminationDate: json['termination_date'],
    );
  }

  String get fullName => '$firstName $lastName';
}
