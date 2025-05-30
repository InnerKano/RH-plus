import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:rh_plus/services/payroll_service.dart';

class PayrollProvider with ChangeNotifier {
  final PayrollService _payrollService;
  
  List<ContractModel> _contracts = [];
  List<PayrollPeriodModel> _periods = [];
  List<PayrollEntryModel> _payrollEntries = [];
  List<PayrollItemModel> _payrollItems = [];
  
  ContractModel? _selectedContract;
  PayrollPeriodModel? _selectedPeriod;
  PayrollEntryModel? _selectedEntry;
  
  bool _isLoading = false;
  String? _error;

  PayrollProvider({required String token})
      : _payrollService = PayrollService(token: token);

  // Getters
  List<ContractModel> get contracts => _contracts;
  List<PayrollPeriodModel> get periods => _periods;
  List<PayrollEntryModel> get payrollEntries => _payrollEntries;
  List<PayrollItemModel> get payrollItems => _payrollItems;
  
  ContractModel? get selectedContract => _selectedContract;
  PayrollPeriodModel? get selectedPeriod => _selectedPeriod;
  PayrollEntryModel? get selectedEntry => _selectedEntry;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Contracts
  Future<void> fetchContracts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contracts = await _payrollService.getContracts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchContractsByEmployee(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contracts = await _payrollService.getContractsByEmployee(employeeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Periods
  Future<void> fetchPayrollPeriods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _periods = await _payrollService.getPayrollPeriods();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchOpenPayrollPeriods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _periods = await _payrollService.getOpenPayrollPeriods();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Payroll entries
  Future<void> fetchPayrollEntriesByPeriod(int periodId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payrollEntries = await _payrollService.getPayrollEntriesByPeriod(periodId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchPayrollEntriesByEmployee(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payrollEntries = await _payrollService.getPayrollEntriesByEmployee(employeeId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Selection methods
  void setSelectedContract(ContractModel contract) {
    _selectedContract = contract;
    notifyListeners();
  }

  void setSelectedPeriod(PayrollPeriodModel period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void setSelectedEntry(PayrollEntryModel entry) {
    _selectedEntry = entry;
    notifyListeners();
  }

  void clearSelectedContract() {
    _selectedContract = null;
    notifyListeners();
  }

  void clearSelectedPeriod() {
    _selectedPeriod = null;
    notifyListeners();
  }

  void clearSelectedEntry() {
    _selectedEntry = null;
    notifyListeners();
  }

  // Create payroll entry
  Future<bool> createPayrollEntry(Map<String, dynamic> entryData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newEntry = await _payrollService.createPayrollEntry(entryData);
      _payrollEntries.add(newEntry);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Approve payroll entry
  Future<bool> approvePayrollEntry(int entryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _payrollService.approvePayrollEntry(entryId);
      if (success) {
        // Update the entry in the local list
        final entryIndex = _payrollEntries.indexWhere((entry) => entry.id == entryId);
        if (entryIndex != -1) {
          // Create a new instance with updated approval status
          final updatedEntry = PayrollEntryModel(
            id: _payrollEntries[entryIndex].id,
            contractId: _payrollEntries[entryIndex].contractId,
            employeeName: _payrollEntries[entryIndex].employeeName,
            periodId: _payrollEntries[entryIndex].periodId,
            periodName: _payrollEntries[entryIndex].periodName,
            totalEarnings: _payrollEntries[entryIndex].totalEarnings,
            totalDeductions: _payrollEntries[entryIndex].totalDeductions,
            netPay: _payrollEntries[entryIndex].netPay,
            isApproved: true,
            details: _payrollEntries[entryIndex].details,
          );
          _payrollEntries[entryIndex] = updatedEntry;
          
          // Update selected entry if it's the same
          if (_selectedEntry?.id == entryId) {
            _selectedEntry = updatedEntry;
          }
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch payroll entry by ID
  Future<void> fetchPayrollEntryById(int entryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final entry = await _payrollService.getPayrollEntryById(entryId);
      _selectedEntry = entry;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // PayrollItems methods
  Future<void> fetchPayrollItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _payrollItems = await _payrollService.getPayrollItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<PayrollItemModel>> fetchPayrollItemsByType(String type) async {
    try {
      return await _payrollService.getPayrollItemsByType(type);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  List<PayrollItemModel> getEarnings() {
    return _payrollItems.where((item) => item.itemType == 'EARNING' && item.isActive).toList();
  }

  List<PayrollItemModel> getDeductions() {
    return _payrollItems.where((item) => item.itemType == 'DEDUCTION' && item.isActive).toList();
  }

  // =============== CONTRACT CRUD METHODS ===============
  
  // Create contract
  Future<bool> createContract(Map<String, dynamic> contractData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newContract = await _payrollService.createContract(contractData);
      _contracts.add(newContract);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update contract
  Future<bool> updateContract(int contractId, Map<String, dynamic> contractData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedContract = await _payrollService.updateContract(contractId, contractData);
      final index = _contracts.indexWhere((contract) => contract.id == contractId);
      if (index != -1) {
        _contracts[index] = updatedContract;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete contract
  Future<bool> deleteContract(int contractId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _payrollService.deleteContract(contractId);
      if (success) {
        _contracts.removeWhere((contract) => contract.id == contractId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =============== PAYROLL PERIOD CRUD METHODS ===============
  
  // Create payroll period
  Future<bool> createPayrollPeriod(Map<String, dynamic> periodData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPeriod = await _payrollService.createPayrollPeriod(periodData);
      _periods.add(newPeriod);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update payroll period
  Future<bool> updatePayrollPeriod(int periodId, Map<String, dynamic> periodData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedPeriod = await _payrollService.updatePayrollPeriod(periodId, periodData);
      final index = _periods.indexWhere((period) => period.id == periodId);
      if (index != -1) {
        _periods[index] = updatedPeriod;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Close payroll period
  Future<bool> closePayrollPeriod(int periodId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _payrollService.closePayrollPeriod(periodId);
      if (success) {
        // Update the period status in local list
        final index = _periods.indexWhere((period) => period.id == periodId);
        if (index != -1) {          // Create updated period with closed status
          final updatedPeriod = PayrollPeriodModel(
            id: _periods[index].id,
            name: _periods[index].name,
            periodType: _periods[index].periodType,
            startDate: _periods[index].startDate,
            endDate: _periods[index].endDate,
            isClosed: true,
          );
          _periods[index] = updatedPeriod;
        }
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete payroll period
  Future<bool> deletePayrollPeriod(int periodId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _payrollService.deletePayrollPeriod(periodId);
      if (success) {
        _periods.removeWhere((period) => period.id == periodId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // =============== PAYROLL ITEM CRUD METHODS ===============
  
  // Create payroll item
  Future<bool> createPayrollItem(Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItem = await _payrollService.createPayrollItem(itemData);
      _payrollItems.add(newItem);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update payroll item
  Future<bool> updatePayrollItem(int itemId, Map<String, dynamic> itemData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _payrollService.updatePayrollItem(itemId, itemData);
      final index = _payrollItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _payrollItems[index] = updatedItem;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle payroll item status
  Future<bool> togglePayrollItemStatus(int itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedItem = await _payrollService.togglePayrollItemStatus(itemId);
      final index = _payrollItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _payrollItems[index] = updatedItem;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete payroll item
  Future<bool> deletePayrollItem(int itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _payrollService.deletePayrollItem(itemId);
      if (success) {
        _payrollItems.removeWhere((item) => item.id == itemId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
