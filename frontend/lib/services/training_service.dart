import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/utils/constants.dart';
import 'package:rh_plus/models/training_models.dart';

class TrainingService {
  final String token;
  
  TrainingService({required this.token});
  
  Future<List<TrainingProgramModel>> getTrainingPrograms() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/programs/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrainingProgramModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load training programs');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<TrainingSessionModel>> getUpcomingSessions() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/sessions/upcoming/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrainingSessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load upcoming training sessions');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<TrainingSessionModel>> getSessionsByProgram(int programId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/sessions/by_program/?program=$programId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrainingSessionModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load training sessions for program');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<TrainingAttendanceModel>> getAttendanceBySession(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/attendances/by_session/?session=$sessionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrainingAttendanceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load training attendances for session');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<List<TrainingAttendanceModel>> getAttendanceByEmployee(int employeeId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/attendances/by_employee/?employee=$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => TrainingAttendanceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load training attendances for employee');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> getAttendanceStats(int sessionId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/training/sessions/$sessionId/attendance_stats/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load attendance statistics');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> createProgram(Map<String, dynamic> programData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/training/programs/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(programData),
      );
      
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create training program');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<Map<String, dynamic>> updateProgram(int programId, Map<String, dynamic> programData) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/training/programs/$programId/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(programData),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update training program');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
  
  Future<void> deleteProgram(int programId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/training/programs/$programId/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete training program');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
