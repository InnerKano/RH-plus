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
      }    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create a new payroll entry
  Future<PayrollEntryModel> createPayrollEntry(Map<String, dynamic> entryData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/entries/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(entryData),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollEntryModel.fromJson(data);
      } else {
        throw Exception('Failed to create payroll entry');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Approve a payroll entry
  Future<bool> approvePayrollEntry(int entryId) async {    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/entries/$entryId/approve/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to approve payroll entry');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get payroll entry by ID
  Future<PayrollEntryModel> getPayrollEntryById(int entryId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/entries/$entryId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollEntryModel.fromJson(data);
      } else {
        throw Exception('Failed to load payroll entry');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get all payroll items
  Future<List<PayrollItemModel>> getPayrollItems() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll items');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get payroll items by type (EARNING or DEDUCTION)
  Future<List<PayrollItemModel>> getPayrollItemsByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/by_type/?type=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PayrollItemModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load payroll items by type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // =============== CONTRACT CRUD METHODS ===============
  
  // Create a new contract
  Future<ContractModel> createContract(Map<String, dynamic> contractData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/contracts/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(contractData),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ContractModel.fromJson(data);
      } else {
        throw Exception('Failed to create contract');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update an existing contract
  Future<ContractModel> updateContract(int contractId, Map<String, dynamic> contractData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/contracts/$contractId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(contractData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ContractModel.fromJson(data);
      } else {
        throw Exception('Failed to update contract');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete a contract
  Future<bool> deleteContract(int contractId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/contracts/$contractId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete contract');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // =============== PAYROLL PERIOD CRUD METHODS ===============
  
  // Create a new payroll period
  Future<PayrollPeriodModel> createPayrollPeriod(Map<String, dynamic> periodData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(periodData),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollPeriodModel.fromJson(data);
      } else {
        throw Exception('Failed to create payroll period');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update an existing payroll period
  Future<PayrollPeriodModel> updatePayrollPeriod(int periodId, Map<String, dynamic> periodData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/$periodId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(periodData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollPeriodModel.fromJson(data);
      } else {
        throw Exception('Failed to update payroll period');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Close a payroll period
  Future<bool> closePayrollPeriod(int periodId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/$periodId/close/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to close payroll period');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete a payroll period
  Future<bool> deletePayrollPeriod(int periodId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/periods/$periodId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete payroll period');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // =============== PAYROLL ITEM CRUD METHODS ===============
  
  // Create a new payroll item
  Future<PayrollItemModel> createPayrollItem(Map<String, dynamic> itemData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(itemData),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollItemModel.fromJson(data);
      } else {
        throw Exception('Failed to create payroll item');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Update an existing payroll item
  Future<PayrollItemModel> updatePayrollItem(int itemId, Map<String, dynamic> itemData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/$itemId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(itemData),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollItemModel.fromJson(data);
      } else {
        throw Exception('Failed to update payroll item');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Toggle payroll item status (active/inactive)
  Future<PayrollItemModel> togglePayrollItemStatus(int itemId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/$itemId/toggle_status/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return PayrollItemModel.fromJson(data);
      } else {
        throw Exception('Failed to toggle payroll item status');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete a payroll item
  Future<bool> deletePayrollItem(int itemId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/payroll/items/$itemId/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Failed to delete payroll item');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
