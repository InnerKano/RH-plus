import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access'];
        _refreshToken = data['refresh'];
        
        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth', _token!);
        if (_refreshToken != null) {
          await prefs.setString('refresh', _refreshToken!);
        }
        
        // Load user permissions
        await loadUserPermissions();
        
        print('AuthProvider: Login successful');
        return {'success': true, 'message': 'Login exitoso'};
      } else {
        final errorData = json.decode(response.body);
        print('AuthProvider: Login failed: ${errorData['message']}');
        return {'success': false, 'message': errorData['message'] ?? 'Credenciales inválidas'};
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
      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth', token);
      
      // Load user permissions with the token
      await loadUserPermissions();
      
      // If we successfully loaded permissions, consider the token valid
      if (_userPermissions != null) {
        print('AuthProvider: Successfully loaded user from token');
        return true;
      }
      
      print('AuthProvider: Failed to load user permissions');
      // Clear invalid token from storage
      await prefs.remove('auth');
      _token = null;
      return false;
    } catch (e) {
      print('AuthProvider: Error loading user from token: $e');
      _token = null;
      // Clear invalid token from storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth');
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userPermissions = UserPermissions.fromJson(data);
        
        // Also load user data if available
        if (data['user'] != null) {
          _user = User.fromJson(data['user']);
          print('AuthProvider: User data updated: ${_user?.email}');
        }
        
        print('AuthProvider: User permissions loaded: ${_userPermissions?.role}');
        notifyListeners();
      } else if (response.statusCode == 401) {
        print('AuthProvider: Token expired or invalid, logging out');
        // Token is invalid, clear auth state
        _token = null;
        _refreshToken = null;
        _user = null;
        _userPermissions = null;
        notifyListeners();
      } else {
        print('AuthProvider: Error loading permissions: ${response.statusCode}');
        print('AuthProvider: Error body: ${response.body}');
      }
    } catch (e) {
      print('AuthProvider: Exception loading user permissions: $e');
    }
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _user = null;
    _userPermissions = null;
    
    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth');
    await prefs.remove('refresh');
    
    notifyListeners();
  }


  Future<bool> loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth');
      final savedRefreshToken = prefs.getString('refresh');
      
      print('AuthProvider: Loading token from storage...');
      print('AuthProvider: Token found: ${savedToken != null}');
      
      if (savedToken != null) {
        _token = savedToken;
        _refreshToken = savedRefreshToken;
        
        // Validar el token cargando permisos
        await loadUserPermissions();
        
        // Si los permisos se cargaron correctamente, el token es válido
        if (_userPermissions != null) {
          print('AuthProvider: Token loaded and validated successfully');
          return true;
        } else {
          // Token inválido, limpiar storage
          print('AuthProvider: Token invalid, clearing storage');
          await logout();
          return false;
        }
      }
      
      print('AuthProvider: No token found in storage');
      return false;
    } catch (e) {
      print('AuthProvider: Error loading token from storage: $e');
      return false;
    }
  }

  bool canAccessModule(String module) {
    return _userPermissions?.canAccessModule(module) ?? false;
  }

  bool get canManageUsers {
    return _userPermissions?.canManageUsers ?? false;
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
