// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService auth;
  AuthProvider(this.auth);

  bool isLoading = false;
  bool isLoggedIn = false;

  // userId for "My Tickets" filters (e.g., assigned_to == userId)
  int userId = -1;

  String userType = '';
  String userSubRole = '';
  bool emailVerified = false;
  String displayName = ''; // <-- NEW

  Future<void> init() async {
    isLoggedIn = await auth.loadSavedSession();
    if (isLoggedIn) {
      final sp = await SharedPreferences.getInstance();
      userType = sp.getString('user_type') ?? '';
      userSubRole = sp.getString('user_sub_role') ?? '';
      emailVerified = sp.getBool('email_verified') ?? false;
      displayName = sp.getString('display_name') ?? '';

      // load persisted user id (if AuthService didn’t already)
      userId = sp.getInt('user_id') ?? -1;

      // If userId is missing but a fallback string exists, try parse
      if (userId == -1) {
        final idStr = sp.getString('user_id') ?? '';
        final parsed = int.tryParse(idStr);
        if (parsed != null) userId = parsed;
      }
    }
    notifyListeners();
  }

  Future<void> doLogin(String email, String password, bool stayLogged) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await auth.login(email, password, stayLoggedIn: stayLogged);
      final user = Map<String, dynamic>.from(data['user'] ?? {});

      // parse and persist user id
      userId = _parseUserId(user);

      userType = (user['user_type'] ?? '').toString();
      userSubRole = (user['user_sub_role'] ?? '').toString();
      emailVerified =
          (user['is_email_verified'] ?? (user['email_verified_at'] != null)) ==
          true;
      displayName = _extractName(user);

      // persist name + user id (other fields are persisted by AuthService)
      final sp = await SharedPreferences.getInstance();
      await sp.setString('display_name', displayName);
      await sp.setInt('user_id', userId);

      isLoggedIn = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String? lastError;

  /// Self-registration for clients. Returns true on success.
  Future<bool> doRegister({
    required String name,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      lastError = null;
      final res = await auth.registerClient(
        name: name,
        email: email,
        password: password,
      );
      final ok = (res['success'] == true);
      if (!ok) {
        lastError = (res['message']?.toString() ?? 'Registration failed.');
      }
      return ok;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> doLogout() async {
    // Optimistic UI: flip to logged-out immediately so UI navigates at once.
    isLoggedIn = false;
    userId = -1; // reset
    userType = '';
    userSubRole = '';
    emailVerified = false;
    displayName = '';
    notifyListeners();

    // Best-effort server + disk cleanup (AuthService clears SharedPreferences and token)
    try {
      await auth.logout();
    } catch (_) {
      // ignore — we already cleared local state and UI
    }
  }

  // Safe user id extraction from login payload
  int _parseUserId(Map<String, dynamic> u) {
    final raw = u['id'] ?? u['user_id'];
    if (raw is int) return raw;
    if (raw is String) {
      final v = int.tryParse(raw);
      if (v != null) return v;
    }
    // As a last resort, try nested user objects if your API wraps them
    final nested = u['user'];
    if (nested is Map) {
      final nraw = nested['id'] ?? nested['user_id'];
      if (nraw is int) return nraw;
      if (nraw is String) {
        final v = int.tryParse(nraw);
        if (v != null) return v;
      }
    }
    return -1;
  }

  String _extractName(Map<String, dynamic> u) {
    final name = (u['name'] ?? u['full_name'] ?? u['fullname'])?.toString();
    if (name != null && name.trim().isNotEmpty) return name.trim();
    final first = (u['first_name'] ?? u['firstname'])?.toString() ?? '';
    final last = (u['last_name'] ?? u['lastname'])?.toString() ?? '';
    final combined = ('$first $last').trim();
    if (combined.isNotEmpty) return combined;
    final username = (u['username'] ?? '').toString();
    if (username.isNotEmpty) return username;
    final email = (u['email'] ?? '').toString();
    return email.contains('@') ? email.split('@').first : 'User';
  }
}
