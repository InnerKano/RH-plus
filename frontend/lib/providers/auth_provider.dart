import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  String? _refreshToken;
  User? _user;
  UserPermissions? _userPermissions;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  User? get user => _user;
  UserPermissions? get userPermissions => _userPermissions;

  bool get isAuthenticated => _token != null;

  Future<Map<String, dynamic>> login(String email, String password) async {
    print('AuthProvider: Starting login for $email');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('AuthProvider: Login response status: ${response.statusCode}');
      print('AuthProvider: Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access'];
        _refreshToken = data['refresh'];
        
        print('AuthProvider: Token received: ${_token?.substring(0, 20)}...');
        
        // Create user object from token data if available
        if (data.containsKey('user')) {
          _user = User.fromJson(data['user']);
          print('AuthProvider: User loaded from login: ${_user?.email}');
        }
        
        // Load user permissions after successful login
        await loadUserPermissions();
        
        notifyListeners();
        return {'success': true, 'message': 'Login exitoso'};
      } else {
        final errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['detail'] ?? 'Error de autenticación'};
      }
    } catch (e) {
      print('AuthProvider: Login error: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadUserFromToken(String token) async {
    print('AuthProvider: Loading user from token: ${token.substring(0, 20)}...');
    _token = token;
    _isLoading = true;
    notifyListeners();

    try {
      // Load user permissions with the token
      await loadUserPermissions();
      
      // If we successfully loaded permissions, consider the token valid
      if (_userPermissions != null) {
        print('AuthProvider: Successfully loaded user from token');
        return true;
      }
      
      print('AuthProvider: Failed to load user permissions');
      return false;
    } catch (e) {
      print('AuthProvider: Error loading user from token: $e');
      _token = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserPermissions() async {
    if (_token == null) {
      print('AuthProvider: No token available for loading permissions');
      return;
    }

    print('AuthProvider: Loading user permissions...');
    
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.userPermissionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      print('AuthProvider: Permissions response status: ${response.statusCode}');
      print('AuthProvider: Permissions response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userPermissions = UserPermissions.fromJson(data);
        print('AuthProvider: User permissions loaded: ${_userPermissions?.role}');
        notifyListeners();
      } else {
        print('AuthProvider: Error loading permissions: ${response.statusCode}');
        print('AuthProvider: Error body: ${response.body}');
      }
    } catch (e) {
      print('AuthProvider: Exception loading user permissions: $e');
    }
  }

  bool canAccessModule(String module) {
    return _userPermissions?.canAccessModule(module) ?? false;
  }

  bool get canManageUsers {
    return _userPermissions?.canManageUsers ?? false;
  }

  void logout() {
    _token = null;
    _refreshToken = null;
    _user = null;
    _userPermissions = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> register(String email, String password, String passwordConfirm, String firstName, String lastName) async {
    print('AuthProvider: Starting registration for $email');
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      print('AuthProvider: Registration response status: ${response.statusCode}');
      print('AuthProvider: Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Usuario registrado exitosamente'};
      } else {
        final errorData = json.decode(response.body);
        print('AuthProvider: Registration errors: $errorData');
        return {'success': false, 'errors': errorData};
      }
    } catch (e) {
      print('AuthProvider: Registration error: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
