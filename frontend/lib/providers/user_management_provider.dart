import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserManagementProvider with ChangeNotifier {
  bool _isLoading = false;
  List<User> _users = [];
  List<Map<String, String>> _availableRoles = [];
  String? _token;
  
  bool get isLoading => _isLoading;
  List<User> get users => _users;
  List<Map<String, String>> get availableRoles => _availableRoles;
  
  void setToken(String? token) {
    _token = token;
  }
  
  Future<void> loadUsers() async {
    if (_token == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.usersUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _users = data.map((user) => User.fromJson(user)).toList();
      }
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadAvailableRoles() async {
    if (_token == null) return;
    
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.roleOptionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _availableRoles = data.map<Map<String, String>>((role) => {
          'code': role['code'].toString(),
          'name': role['name'].toString(),
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading available roles: $e');
    }
  }
  
  Future<Map<String, dynamic>> updateUserRole(
    String userId,
    String role,
    String? department,
    String? managerId,
  ) async {
    if (_token == null) {
      return {'success': false, 'message': 'No autenticado'};
    }
    
    try {
      final body = {
        'role': role,
        if (department != null) 'department': department,
        if (managerId != null) 'manager': managerId,
      };
      
      final response = await http.patch(
        Uri.parse('${ApiConstants.updateUserRoleUrl}/$userId/update_role/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(json.decode(response.body));
        final index = _users.indexWhere((user) => user.id == updatedUser.id);
        if (index != -1) {
          _users[index] = updatedUser;
          notifyListeners();
        }
        return {'success': true, 'message': 'Rol actualizado exitosamente'};
      } else {
        final errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['error'] ?? 'Error desconocido'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
