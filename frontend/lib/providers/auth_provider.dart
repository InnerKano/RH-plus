import 'dart:convert';
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
  bool get isAuthenticated => _token != null && _currentUser != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/core/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _isLoading = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['access'];
        await _storage.write(key: 'auth_token', value: _token);
        await _storage.write(key: 'refresh_token', value: data['refresh']);

        // Fetch user data
        await _fetchUserData();
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserFromToken(String token) async {
    _token = token;
    await _fetchUserData();
    notifyListeners();
  }

  Future<void> _fetchUserData() async {
    if (_token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/api/core/users/me/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data);
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
