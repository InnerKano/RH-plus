import 'package:flutter/foundation.dart';
import 'package:rh_plus/models/employee_model.dart';
import 'package:rh_plus/services/employee_service.dart';

class EmployeeProvider with ChangeNotifier {
  final EmployeeService _employeeService;
  List<EmployeeModel> _employees = [];
  EmployeeModel? _selectedEmployee;
  bool _isLoading = false;
  String? _error;

  EmployeeProvider({required String token})
      : _employeeService = EmployeeService(token: token);

  List<EmployeeModel> get employees => _employees;
  EmployeeModel? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await _employeeService.getEmployees();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchEmployeeById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await _employeeService.getEmployeeById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchEmployeeByDocument(String documentNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await _employeeService.getEmployeeByDocument(documentNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEmployee = await _employeeService.updateEmployee(id, employeeData);
      
      // Update in the list
      final index = _employees.indexWhere((e) => e.id == id);
      if (index >= 0) {
        _employees[index] = updatedEmployee;
      }
      
      // Update selected employee if it's the same
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = updatedEmployee;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setSelectedEmployee(EmployeeModel employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void clearSelectedEmployee() {
    _selectedEmployee = null;
    notifyListeners();
  }

  List<EmployeeModel> filterByDepartment(String department) {
    return _employees.where((employee) => employee.department == department).toList();
  }

  List<EmployeeModel> filterByStatus(String status) {
    return _employees.where((employee) => employee.status == status).toList();
  }
}
