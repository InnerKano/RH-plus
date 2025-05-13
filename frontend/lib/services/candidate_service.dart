import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/candidate_model.dart';

class CandidateService {
  final String token;
  
  CandidateService({required this.token});
  
  Future<List<CandidateModel>> getCandidates() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/selection/candidates/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CandidateModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load candidates');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<CandidateModel> getCandidateById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/selection/candidates/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return CandidateModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load candidate');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<CandidateModel> createCandidate(Map<String, dynamic> candidateData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/selection/candidates/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(candidateData),
      );
      
      if (response.statusCode == 201) {
        return CandidateModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create candidate');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<CandidateModel> updateCandidate(int id, Map<String, dynamic> candidateData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/selection/candidates/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(candidateData),
      );
      
      if (response.statusCode == 200) {
        return CandidateModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update candidate');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
