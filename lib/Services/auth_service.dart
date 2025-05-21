import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth;

  AuthService._internal() : _auth = FirebaseAuth.instance {
    _initializeFirebase();
  }

  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _initializeFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
        print('Firebase initialized successfully.');
      }
    } catch (e) {
      print('Firebase initialization failed: $e');
      throw AuthException(
        'firebase-init-failed',
        'Failed to initialize Firebase: $e',
      );
    }
  }

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        throw AuthException(
          'email-not-verified',
          'Please verify your email before logging in.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      throw AuthException(e.code, _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      print('Unexpected login error: $e');
      throw AuthException(
        'unknown',
        'An unexpected error occurred during login: $e',
      );
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.sendEmailVerification();
        print('Verification email sent to: $email');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      throw AuthException(e.code, _mapFirebaseErrorToMessage(e.code));
    } catch (e) {
      print('Unexpected registration error: $e');
      throw AuthException(
        'unknown',
        'An unexpected error occurred during registration: $e',
      );
    }
  }

  /// Google Sign-In for Windows desktop using OAuth web flow.
  Future<User?> signInWithGoogle() async {
    try {
      await _initializeFirebase();
      await dotenv.load(); // Load environment variables

      final clientId = dotenv.env['GOOGLE_OAUTH_CLIENT_ID'];
      final clientSecret = dotenv.env['GOOGLE_OAUTH_CLIENT_SECRET'];
      final redirectUri = dotenv.env['GOOGLE_OAUTH_REDIRECT_URI'];

      if (clientId == null || clientId.isEmpty) {
        throw AuthException(
          'missing-config',
          'Google Client ID not configured',
        );
      }
      if (clientSecret == null || clientSecret.isEmpty) {
        throw AuthException(
          'missing-config',
          'Google Client Secret not configured',
        );
      }
      if (redirectUri == null || redirectUri.isEmpty) {
        throw AuthException('missing-config', 'Redirect URI not configured');
      }

      final authUrl = Uri.https('accounts.google.com', '/o/oauth2/auth', {
        'response_type': 'code',
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'scope': 'openid email profile',
        'access_type': 'offline',
        'prompt': 'consent',
      });

      print('Initiating Google Sign-In...');

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: Uri.parse(redirectUri).scheme, // 'http' or 'https'
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) {
        throw AuthException(
          'no-auth-code',
          'Authorization failed: no code returned',
        );
      }

      final tokenResponse = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'client_id': clientId,
          'client_secret': clientSecret,
          'redirect_uri': redirectUri,
          'grant_type': 'authorization_code',
          'code': code,
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw AuthException(
          'token-exchange-failed',
          'Failed to exchange code: ${tokenResponse.body}',
        );
      }

      final tokens = json.decode(tokenResponse.body);
      final credential = GoogleAuthProvider.credential(
        idToken: tokens['id_token'],
        accessToken: tokens['access_token'],
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google Sign-In error: $e');
      throw AuthException(
        'google-sign-in-failed',
        'Google Sign-In failed: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Sign-out error: $e');
      throw AuthException('sign-out-failed', 'Failed to sign out: $e');
    }
  }

  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      print('Email verified status: ${user.emailVerified}');
      return user.emailVerified;
    }
    return false;
  }

  String _mapFirebaseErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account exists with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-not-verified':
        return 'Please verify your email before logging in.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return 'An error occurred: $code';
    }
  }
}

class AuthException implements Exception {
  final String code;
  final String message;

  AuthException(this.code, this.message);

  @override
  String toString() => 'AuthException(code: $code, message: $message)';
}
