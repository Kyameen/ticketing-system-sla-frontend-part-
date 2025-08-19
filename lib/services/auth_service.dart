// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

/// Handles login / logout and local session persistence.
class AuthService {
  final ApiClient api;
  AuthService(this.api);

  /// POST /api/login  -> { success, token, user:{...} }
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool stayLoggedIn = true,
  }) async {
    final res = await api.post('/login', {
      'email': email.trim(),
      'password': password,
    });

    late final Map<String, dynamic> body;
    try {
      body = Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (_) {
      throw Exception('Bad response (${res.statusCode})');
    }

    if (res.statusCode >= 200 &&
        res.statusCode < 300 &&
        body['success'] == true &&
        body['token'] != null) {
      final token = body['token'] as String;
      final user = Map<String, dynamic>.from(body['user'] ?? {});
      api.setToken(token);

      final sp = await SharedPreferences.getInstance();
      if (stayLoggedIn) await sp.setString('auth_token', token);
      await sp.setString('user_type', (user['user_type'] ?? '').toString());
      await sp.setString(
        'user_sub_role',
        (user['user_sub_role'] ?? '').toString(),
      );
      await sp.setBool(
        'email_verified',
        (user['is_email_verified'] ?? (user['email_verified_at'] != null)) ==
            true,
      );

      return {'success': true, 'token': token, 'user': user};
    }

    final msg = (body['message'] ?? 'Login failed (${res.statusCode})')
        .toString();
    throw Exception(msg);
  }

  /// POST /api/logout  (best-effort)
  Future<void> logout() async {
    try {
      await api.post('/logout', {});
    } catch (_) {}
    final sp = await SharedPreferences.getInstance();
    await sp.clear();
    api.setToken(null);
  }

  /// Load saved token from disk (for "stay logged in")
  Future<bool> loadSavedSession() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('auth_token');
    api.setToken(token);
    return token != null;
  }

  /// POST /api/register  -> usually returns { success, message, user? }
  /// We intentionally do NOT auto-login after register (email verify first).
  /// POST /api/register  -> returns success or validation error.
  Future<Map<String, dynamic>> registerClient({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await api.post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      // Important for your RBAC: force client self-registration
      'user_type': 'client',
    });

    Map<String, dynamic> body = {};
    try {
      if (res.body.isNotEmpty) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) body = Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}

    final success = res.statusCode >= 200 && res.statusCode < 300;

    // Try to extract a human message for failures
    String? message;
    if (!success) {
      message = body['message']?.toString();
      if (message == null && body['errors'] is Map) {
        final errors = Map<String, dynamic>.from(body['errors']);
        // pick the first error string we find
        for (final v in errors.values) {
          if (v is List && v.isNotEmpty) {
            message = v.first.toString();
            break;
          } else if (v is String && v.isNotEmpty) {
            message = v;
            break;
          }
        }
      }
      message ??= 'Registration failed. Please check your details.';
    }

    return {
      'success': success,
      'data': body,
      if (!success) 'message': message,
      'status': res.statusCode,
    };
  }
}
