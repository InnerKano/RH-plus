import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/payroll_models.dart';

class PayrollService {
  final String token;
  
  PayrollService({required this.token});
  
  Future<List<ContractModel>> getContracts() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/contracts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ContractModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contracts');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<ContractModel>> getContractsByEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/contracts/by_employee/?employee=$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ContractModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contracts for employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<PayrollPeriodModel>> getPayrollPeriods() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollPeriodModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll periods');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<PayrollPeriodModel>> getOpenPayrollPeriods() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/open/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollPeriodModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load open payroll periods');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<PayrollEntryModel>> getPayrollEntriesByPeriod(int periodId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/entries/by_period/?period=$periodId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollEntryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll entries for period');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<PayrollEntryModel>> getPayrollEntriesByEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/entries/by_employee/?employee=$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollEntryModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll entries for employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
