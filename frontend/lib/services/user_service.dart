import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_plus/models/user_model.dart';
import 'package:rh_plus/utils/constants.dart';

class UserService {
  final String token;
  
  UserService({required this.token});
  
  Future<List<User>> getEmployeeUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/users/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Filter users with EMPLOYEE role
        final employeeUsers = data
          .where((user) => user['role'] == 'EMPLOYEE' && user['is_active'] == true)
          .toList();
        return employeeUsers.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load employee users');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
