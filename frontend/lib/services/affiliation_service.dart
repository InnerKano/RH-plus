import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/affiliation_models.dart';

class AffiliationService {
  final String token;
  
  AffiliationService({required this.token});

  // AffiliationType endpoints
  Future<List<AffiliationType>> getAffiliationTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/affiliation-types/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => AffiliationType.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load affiliation types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  // InsuranceProvider endpoints
  Future<List<InsuranceProvider>> getProviders() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/providers/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InsuranceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load providers');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<InsuranceProvider>> getProvidersByType(int typeId) async {    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/providers/by_type/?type_id=$typeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => InsuranceProvider.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load providers for type');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Affiliation endpoints
  Future<List<Affiliation>> getAffiliations() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/affiliations/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Affiliation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load affiliations');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Affiliation>> getAffiliationsByEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/affiliations/by_employee/?employee_id=$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Affiliation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load affiliations for employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Affiliation> createAffiliation(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/affiliations/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Affiliation.fromJson(responseData);
      } else {
        throw Exception('Failed to create affiliation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Affiliation> updateAffiliation(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/affiliation/affiliations/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return Affiliation.fromJson(responseData);
      } else {
        throw Exception('Failed to update affiliation: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
