import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/employee_model.dart';

class EmployeeService {
  final String token;
  
  EmployeeService({required this.token});
  
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/employees/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EmployeeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employees');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<EmployeeModel> getEmployeeById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/employees/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return EmployeeModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<EmployeeModel> getEmployeeByDocument(String documentNumber) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/employees/by_document/?document=$documentNumber'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return EmployeeModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Employee not found');
      } else {
        throw Exception('Failed to load employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<EmployeeModel> updateEmployee(int id, Map<String, dynamic> employeeData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/employees/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(employeeData),
      );
      
      if (response.statusCode == 200) {
        return EmployeeModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
