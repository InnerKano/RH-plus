import 'dart:convert';
import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rh_plus/models/user_model.dart';
import 'package:rh_plus/utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _currentUser != null;  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (kDebugMode) {
        print('Intentando iniciar sesión con email: $email');
        print('URL de login: ${ApiConstants.loginUrl}');
      }

      final response = await http.post(
        Uri.parse(ApiConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;

      if (kDebugMode) {
        print('Código de estado de respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access'];
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'refresh_token', value: data['refresh']);

        if (kDebugMode) {
          print('Token obtenido exitosamente. Obteniendo datos del usuario...');
        }

        // Fetch user data
        await _fetchUserData();
        
        if (kDebugMode) {
          print('Usuario autenticado: ${_currentUser != null ? 'Sí' : 'No'}');
        }
        
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('Error en la autenticación: ${response.body}');
        }
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en login: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
    Future<Map<String, dynamic>> register(String email, String password, String passwordConfirm, 
      String firstName, String lastName, String registerType,
      {String? companyName, String? companyTaxId, String? companyAddress, 
      String? companyPhone, String? companyEmail, String? companyWebsite, int? companyId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (kDebugMode) {
        print('Intentando registrar usuario con email: $email');
        print('URL de registro: ${ApiConstants.registerUrl}');
        print('Tipo de registro: $registerType');
      }

      // Crear objeto de datos base
      final Map<String, dynamic> requestData = {
        'email': email,
        'password': password,
        'password_confirm': passwordConfirm,
        'first_name': firstName,
        'last_name': lastName,
        'register_type': registerType,
      };
      
      // Añadir campos específicos según el tipo de registro
      if (registerType == 'new_company') {
        requestData.addAll({
          'company_name': companyName,
          'company_tax_id': companyTaxId,
          'company_address': companyAddress,
          'company_phone': companyPhone,
          if (companyEmail != null) 'company_email': companyEmail,
          if (companyWebsite != null) 'company_website': companyWebsite,
        });
      } else if (registerType == 'join_company') {
        requestData['company_id'] = companyId;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      _isLoading = false;
      notifyListeners();

      if (kDebugMode) {
        print('Código de estado de respuesta: ${response.statusCode}');
        print('Cuerpo de respuesta: ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Usuario registrado exitosamente'
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Error al registrar usuario',
          'errors': responseData
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Excepción en registro: $e');
      }
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error de conexión: $e'
      };
    }
  }
  Future<void> loadUserFromToken(String token) async {
    _token = token;
    if (kDebugMode) {
      print('Cargando usuario desde token guardado');
    }
    await _fetchUserData();
    if (kDebugMode) {
      print('Usuario cargado desde token: ${_currentUser != null ? 'Sí' : 'No'}');
    }
    notifyListeners();
  }Future<void> _fetchUserData() async {
    if (_token == null) {
      if (kDebugMode) {
        print('No se puede obtener datos del usuario: token es nulo');
      }
      return;
    }

    try {
      String url = ApiConstants.userProfileUrl;
      if (kDebugMode) {
        print('Obteniendo datos de usuario desde: $url');
        print('Token utilizado: ${_token!.substring(0, Math.min(10, _token!.length))}...');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (kDebugMode) {
        print('Respuesta de datos de usuario - Código: ${response.statusCode}');
        print('Respuesta de datos de usuario - Cuerpo: ${response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data);
        if (kDebugMode) {
          print('Usuario cargado exitosamente: ${_currentUser?.email}');
        }
      } else {
        if (kDebugMode) {
          print('Error al obtener datos del usuario. Código: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
    notifyListeners();
  }
}
