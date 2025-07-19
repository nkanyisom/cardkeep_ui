import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleAuthService extends ChangeNotifier {
  String? _jwtToken;
  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String? get jwtToken => _jwtToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _jwtToken != null;

  // Base URL for your Spring Boot backend
  static const String baseUrl = 'http://https://cardkeep-backend.onrender.com';

  SimpleAuthService() {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString('jwt_token');
      final userJson = prefs.getString('current_user');

      if (_jwtToken != null && userJson != null) {
        _currentUser = jsonDecode(userJson);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading stored token: $e');
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Signup response: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          _jwtToken = data['token'];
          _currentUser = data['user'] ?? {'email': email};

          // Store in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _jwtToken!);
          await prefs.setString('current_user', jsonEncode(_currentUser));

          notifyListeners();
          return true;
        }
      }

      _errorMessage = 'Failed to create account: ${response.body}';
      return false;
    } catch (e) {
      print('Signup error: $e');
      _errorMessage =
          'Network error: Unable to connect to server. Please check if your backend is running on $baseUrl';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Login response: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['token'] != null) {
          _jwtToken = data['token'];
          _currentUser = data['user'] ?? {'email': email};

          // Store in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _jwtToken!);
          await prefs.setString('current_user', jsonEncode(_currentUser));

          notifyListeners();
          return true;
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid email or password';
        return false;
      } else if (response.statusCode == 400) {
        _errorMessage =
            'Bad request: Please check your email and password format';
        return false;
      }

      _errorMessage = 'Login failed: ${response.body}';
      return false;
    } catch (e) {
      print('Login error: $e');
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup')) {
        _errorMessage =
            'Cannot connect to server. Please ensure your Spring Boot backend is running on $baseUrl';
      } else {
        _errorMessage = 'Network error: $e';
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _jwtToken = null;
    _currentUser = null;
    _errorMessage = null;

    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('current_user');

    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
