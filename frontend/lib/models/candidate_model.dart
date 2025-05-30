class CandidateModel {
  final int id;
  final String firstName;
  final String lastName;
  final String documentType;
  final String documentNumber;
  final String email;
  final String phone;
  final String gender;
  final String birthDate;
  final String address;
  final String status;
  final int? currentStageId;
  String? currentStageName;
  final String createdAt;

  CandidateModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.documentType,
    required this.documentNumber,
    required this.email,
    required this.phone,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.status,
    this.currentStageId,
    this.currentStageName,
    required this.createdAt,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      documentType: json['document_type'],
      documentNumber: json['document_number'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      address: json['address'],
      status: json['status'],
      currentStageId: json['current_stage'],
      currentStageName: json['current_stage_name'],
      createdAt: json['created_at'],
    );
  }

  String get fullName => '$firstName $lastName';
}
