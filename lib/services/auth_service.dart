import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_keep/models/user.dart';

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _jwtToken;

  // Keys for SharedPreferences
  static const String _jwtTokenKey = 'jwt_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get jwtToken => _jwtToken;

  AuthService() {
    // Listen to auth state changes
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    // Load stored JWT token
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString(_jwtTokenKey);

      // Load stored user data if available
      final userId = prefs.getString(_userIdKey);
      final userEmail = prefs.getString(_userEmailKey);

      if (userId != null && userEmail != null && _jwtToken != null) {
        _currentUser = User(
          id: userId,
          email: userEmail,
          createdAt: DateTime.now(), // We don't store this, so use current time
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle any errors silently
    }
  }

  Future<void> _storeToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_jwtTokenKey, token);
      _jwtToken = token;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _storeUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, user.id);
      await prefs.setString(_userEmailKey, user.email);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _clearStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_jwtTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      _jwtToken = null;
    } catch (e) {
      // Handle error silently
    }
  }

  void _onAuthStateChanged(firebase_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      _currentUser = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        createdAt: firebaseUser.metadata.creationTime,
      );

      // Get and store JWT token
      final token = await firebaseUser.getIdToken();
      if (token != null) {
        await _storeToken(token);
      }
      await _storeUserData(_currentUser!);
    } else {
      _currentUser = null;
      await _clearStoredData();
    }
    notifyListeners();
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = User(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          createdAt: credential.user!.metadata.creationTime,
        );

        // Get and store JWT token
        final token = await credential.user!.getIdToken();
        if (token != null) {
          await _storeToken(token);
        }
        await _storeUserData(_currentUser!);

        notifyListeners();
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        _currentUser = User(
          id: credential.user!.uid,
          email: credential.user!.email ?? email,
          createdAt: credential.user!.metadata.creationTime,
        );

        // Get and store JWT token
        final token = await credential.user!.getIdToken();
        if (token != null) {
          await _storeToken(token);
        }
        await _storeUserData(_currentUser!);

        notifyListeners();
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _clearError();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        _setLoading(false);
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _currentUser = User(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          createdAt: userCredential.user!.metadata.creationTime,
        );

        // Get and store JWT token
        final token = await userCredential.user!.getIdToken();
        if (token != null) {
          await _storeToken(token);
        }
        await _storeUserData(_currentUser!);

        notifyListeners();
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred during Google sign-in');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      _currentUser = null;
      await _clearStoredData();
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    }
  }

  /// Get current Firebase ID token
  Future<String?> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          await _storeToken(token);
        }
        return token;
      }
      return _jwtToken; // Return stored token if no current user
    } catch (e) {
      return _jwtToken; // Return stored token on error
    }
  }

  /// Refresh the JWT token
  Future<String?> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final token = await user.getIdToken(true); // Force refresh
        if (token != null) {
          await _storeToken(token);
        }
        return token;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
