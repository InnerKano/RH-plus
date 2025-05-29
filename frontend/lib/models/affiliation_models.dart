class AffiliationType {
  final int id;
  final String name;
  final String? description;

  AffiliationType({
    required this.id,
    required this.name,
    this.description,
  });

  factory AffiliationType.fromJson(Map<String, dynamic> json) {
    return AffiliationType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class InsuranceProvider {
  final int id;
  final String name;
  final int affiliationType;
  final String affiliationTypeName;
  final String? nit;
  final String? address;
  final String? contactPhone;
  final String? contactEmail;
  final bool isActive;

  InsuranceProvider({
    required this.id,
    required this.name,
    required this.affiliationType,
    required this.affiliationTypeName,
    this.nit,
    this.address,
    this.contactPhone,
    this.contactEmail,
    required this.isActive,
  });  factory InsuranceProvider.fromJson(Map<String, dynamic> json) {
    return InsuranceProvider(
      id: json['id'],
      name: json['name'],
      affiliationType: json['affiliation_type'],
      affiliationTypeName: json['affiliation_type_name'],
      nit: json['nit'],
      address: json['address'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      isActive: json['is_active'],
    );
  }
}

class Affiliation {
  final int id;
  final int employee;
  final String employeeName;
  final int provider;
  final String providerName;
  final String affiliationTypeName;
  final String? affiliationNumber;
  final String startDate;
  final String? endDate;
  final bool isActive;

  Affiliation({
    required this.id,
    required this.employee,
    required this.employeeName,
    required this.provider,
    required this.providerName,
    required this.affiliationTypeName,
    this.affiliationNumber,
    required this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Affiliation.fromJson(Map<String, dynamic> json) {
    return Affiliation(
      id: json['id'],
      employee: json['employee'],
      employeeName: json['employee_name'],
      provider: json['provider'],
      providerName: json['provider_name'],
      affiliationTypeName: json['affiliation_type_name'],
      affiliationNumber: json['affiliation_number'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isActive: json['is_active'],
    );
  }
}
