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
}
