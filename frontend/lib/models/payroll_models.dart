// Helper function to safely convert dynamic values to double
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

class ContractModel {
  final int id;
  final int employeeId;
  final String employeeName;
  final String contractType;
  final String position;
  final String department;
  final String startDate;
  final String? endDate;
  final double salary;
  final String currency;
  final String workSchedule;
  final bool isActive;

  ContractModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.contractType,
    required this.position,
    required this.department,
    required this.startDate,
    this.endDate,
    required this.salary,
    required this.currency,
    required this.workSchedule,
    required this.isActive,
  });
  factory ContractModel.fromJson(Map<String, dynamic> json) {
    return ContractModel(
      id: json['id'],
      employeeId: json['employee'],
      employeeName: json['employee_name'] ?? '',
      contractType: json['contract_type'],
      position: json['position'],
      department: json['department'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      salary: _toDouble(json['salary']),
      currency: json['currency'] ?? 'COP',
      workSchedule: json['work_schedule'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class PayrollPeriodModel {
  final int id;
  final String name;
  final String periodType;
  final String startDate;
  final String endDate;
  final bool isClosed;
  final String? closedAt;

  PayrollPeriodModel({
    required this.id,
    required this.name,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
    this.closedAt,
  });
  factory PayrollPeriodModel.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodModel(
      id: json['id'],
      name: json['name'],
      periodType: json['period_type'] ?? 'MONTHLY',
      startDate: json['start_date'],
      endDate: json['end_date'],
      isClosed: json['is_closed'] ?? false,
      closedAt: json['closed_at'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayrollPeriodModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class PayrollEntryModel {
  final int id;
  final int contractId;
  final String employeeName;
  final int periodId;
  final String periodName;
  final double totalEarnings;
  final double totalDeductions;
  final double netPay;
  final bool isApproved;
  final List<PayrollEntryDetailModel> details;

  PayrollEntryModel({
    required this.id,
    required this.contractId,
    required this.employeeName,
    required this.periodId,
    required this.periodName,
    required this.totalEarnings,
    required this.totalDeductions,
    required this.netPay,
    required this.isApproved,
    required this.details,
  });

  factory PayrollEntryModel.fromJson(Map<String, dynamic> json) {
    List<PayrollEntryDetailModel> detailsList = [];
    if (json['details'] != null) {
      detailsList = (json['details'] as List)
          .map((detail) => PayrollEntryDetailModel.fromJson(detail))
          .toList();
    }    return PayrollEntryModel(
      id: json['id'],
      contractId: json['contract'],
      employeeName: json['employee_name'] ?? '',
      periodId: json['period'],
      periodName: json['period_name'] ?? '',
      totalEarnings: _toDouble(json['total_earnings']),
      totalDeductions: _toDouble(json['total_deductions']),
      netPay: _toDouble(json['net_pay']),
      isApproved: json['is_approved'] ?? false,
      details: detailsList,
    );
  }
}

class PayrollItemModel {
  final int id;
  final String name;
  final String code;
  final String itemType; // 'EARNING' or 'DEDUCTION'
  final bool isActive;
  final double? defaultAmount;
  final bool isPercentage;
  final String? description;

  PayrollItemModel({
    required this.id,
    required this.name,
    required this.code,
    required this.itemType,
    required this.isActive,
    this.defaultAmount,
    required this.isPercentage,
    this.description,
  });

  factory PayrollItemModel.fromJson(Map<String, dynamic> json) {
    return PayrollItemModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      itemType: json['item_type'],
      isActive: json['is_active'] ?? true,
      defaultAmount: json['default_amount'] != null ? _toDouble(json['default_amount']) : null,
      isPercentage: json['is_percentage'] ?? false,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'item_type': itemType,
      'is_active': isActive,
      'default_amount': defaultAmount,
      'is_percentage': isPercentage,
      'description': description,
    };
  }
}

class PayrollEntryDetailModel {
  final int id;
  final int payrollEntryId;
  final int payrollItemId;
  final String itemName;
  final String itemType;
  final double amount;
  final double quantity;
  final String? notes;

  PayrollEntryDetailModel({
    required this.id,
    required this.payrollEntryId,
    required this.payrollItemId,
    required this.itemName,
    required this.itemType,
    required this.amount,
    required this.quantity,
    this.notes,
  });
  factory PayrollEntryDetailModel.fromJson(Map<String, dynamic> json) {
    return PayrollEntryDetailModel(
      id: json['id'],
      payrollEntryId: json['payroll_entry'],
      payrollItemId: json['payroll_item'],
      itemName: json['item_name'] ?? '',
      itemType: json['item_type'] ?? '',
      amount: _toDouble(json['amount']),
      quantity: _toDouble(json['quantity']),
      notes: json['notes'],
    );
  }
}
