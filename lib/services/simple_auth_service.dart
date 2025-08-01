import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_keep/services/offline_cache_service.dart';

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
  static const String baseUrl = 'https://cardkeep-backend.onrender.com';

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

        // Set current user in cache for data isolation
        try {
          final cacheService = OfflineCacheService();
          String userId = _currentUser!['id']?.toString() ??
              _currentUser!['email'] ??
              'unknown';
          await cacheService.setCurrentUser(userId);
          print('🔄 Restored current user in cache: $userId');
        } catch (e) {
          print('⚠️ Error restoring current user in cache: $e');
        }

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
      final signupUrl = '$baseUrl/api/auth/signup';
      print('🔍 DEBUG: Signup URL being used: $signupUrl');
      print('🔍 DEBUG: Base URL: $baseUrl');

      final response = await http
          .post(
            Uri.parse(signupUrl),
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

        // Check for successful registration message
        if (data['message'] != null &&
            data['message'].toString().toLowerCase().contains('success')) {
          // Registration successful, but user is not automatically logged in
          // Clear any error messages
          _errorMessage = null;
          notifyListeners();
          return true;
        } else if (data['token'] != null) {
          // This handles the case where signup also logs in the user (if backend changes)
          _jwtToken = data['token'];
          _currentUser = data; // Store the full response data

          // Set current user in cache for data isolation
          try {
            final cacheService = OfflineCacheService();
            String userId = data['id']?.toString() ?? data['email'] ?? email;
            await cacheService.setCurrentUser(userId);
            print('🔑 Set current user in cache: $userId');
          } catch (e) {
            print('⚠️ Error setting current user in cache: $e');
          }

          // Store in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _jwtToken!);
          await prefs.setString('current_user', jsonEncode(_currentUser));

          notifyListeners();
          return true;
        } else {
          // Successful status but unexpected response format
          print('⚠️ Unexpected success response format: $data');
          _errorMessage = null; // Clear any previous errors
          notifyListeners();
          return true; // Still consider it successful since status is 200/201
        }
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Registration failed';
        return false;
      } else {
        // Non-success status codes
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Failed to create account';
        return false;
      }
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
      final loginUrl = '$baseUrl/api/auth/login';
      print('🔍 DEBUG: Login URL being used: $loginUrl');
      print('🔍 DEBUG: Base URL: $baseUrl');

      final response = await http
          .post(
            Uri.parse(loginUrl),
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
          _currentUser = data; // Store the full response data

          // Set current user in cache for data isolation
          try {
            final cacheService = OfflineCacheService();
            String userId = data['id']?.toString() ?? data['email'] ?? email;
            await cacheService.setCurrentUser(userId);
            print('🔑 Set current user in cache: $userId');
          } catch (e) {
            print('⚠️ Error setting current user in cache: $e');
          }

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

    // Clear offline cache to prevent data leakage between users
    try {
      final OfflineCacheService cacheService = OfflineCacheService();
      await cacheService.clearCache();
      print('🧹 Cache cleared on logout');
    } catch (e) {
      print('⚠️ Error clearing cache on logout: $e');
    }

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
