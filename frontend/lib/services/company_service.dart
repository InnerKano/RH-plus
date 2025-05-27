import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/models/company.dart';
import 'package:rh_plus/models/company_user.dart';
import 'package:rh_plus/services/api_client.dart';

class CompanyService {
  final ApiClient _apiClient;

  CompanyService(this._apiClient);

  // Get all companies
  Future<List<Company>> getCompanies() async {
    final response = await _apiClient.get('/companies/');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Company.fromJson(json)).toList();
  }

  // Get active companies
  Future<List<Company>> getActiveCompanies() async {
    final response = await _apiClient.get('/companies/active/');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Company.fromJson(json)).toList();
  }

  // Get company details
  Future<Company> getCompany(int id) async {
    final response = await _apiClient.get('/companies/$id/');
    return Company.fromJson(json.decode(response.body));
  }

  // Create a new company
  Future<Company> createCompany(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/companies/', data);
    return Company.fromJson(json.decode(response.body));
  }

  // Update a company
  Future<Company> updateCompany(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put('/companies/$id/', data);
    return Company.fromJson(json.decode(response.body));
  }

  // Approve a company
  Future<void> approveCompany(int id) async {
    await _apiClient.post('/companies/$id/approve/', {});
  }

  // Reject a company
  Future<void> rejectCompany(int id) async {
    await _apiClient.post('/companies/$id/reject/', {});
  }

  // Get pending companies
  Future<List<Company>> getPendingCompanies() async {
    final response = await _apiClient.get('/companies/pending/');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Company.fromJson(json)).toList();
  }

  // Get company users
  Future<List<CompanyUser>> getCompanyUsers(int companyId) async {
    final response = await _apiClient.get('/company-users/?company=$companyId');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => CompanyUser.fromJson(json)).toList();
  }

  // Get user's companies
  Future<List<CompanyUser>> getUserCompanies() async {
    final response = await _apiClient.get('/company-users/my_companies/');
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => CompanyUser.fromJson(json)).toList();
  }

  // Switch active company
  Future<void> switchCompany(int companyId) async {
    await _apiClient.get('/users/switch_company/?company_id=$companyId');
  }

  // Approve a company user
  Future<void> approveCompanyUser(int id) async {
    await _apiClient.post('/company-users/$id/approve/', {});
  }

  // Reject a company user
  Future<void> rejectCompanyUser(int id) async {
    await _apiClient.post('/company-users/$id/reject/', {});
  }

  // Update user roles in a company
  Future<void> updateUserRoles(int companyUserId, List<int> roleIds) async {
    await _apiClient.post('/company-users/$companyUserId/update_roles/', {
      'roles': roleIds
    });
  }
}
