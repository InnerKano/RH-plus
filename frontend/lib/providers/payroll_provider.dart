import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/payroll_models.dart';
import 'package:rh_plus/services/payroll_service.dart';

class PayrollProvider with ChangeNotifier {
  final PayrollService _payrollService;
  
  List<ContractModel> _contracts = [];
  List<PayrollPeriodModel> _periods = [];
  List<PayrollEntryModel> _payrollEntries = [];
  
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
}
