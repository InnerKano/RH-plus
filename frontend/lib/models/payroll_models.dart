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
      salary: json['salary']?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'COP',
      workSchedule: json['work_schedule'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class PayrollPeriodModel {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final bool isClosed;
  final String? closedAt;

  PayrollPeriodModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isClosed,
    this.closedAt,
  });

  factory PayrollPeriodModel.fromJson(Map<String, dynamic> json) {
    return PayrollPeriodModel(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      isClosed: json['is_closed'] ?? false,
      closedAt: json['closed_at'],
    );
  }
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
    }

    return PayrollEntryModel(
      id: json['id'],
      contractId: json['contract'],
      employeeName: json['employee_name'] ?? '',
      periodId: json['period'],
      periodName: json['period_name'] ?? '',
      totalEarnings: json['total_earnings']?.toDouble() ?? 0.0,
      totalDeductions: json['total_deductions']?.toDouble() ?? 0.0,
      netPay: json['net_pay']?.toDouble() ?? 0.0,
      isApproved: json['is_approved'] ?? false,
      details: detailsList,
    );
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
      amount: json['amount']?.toDouble() ?? 0.0,
      quantity: json['quantity']?.toDouble() ?? 1.0,
      notes: json['notes'],
    );
  }
}
