// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService auth;
  AuthProvider(this.auth);

  bool isLoading = false;
  bool isLoggedIn = false;
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
    }
    notifyListeners();
  }

  Future<void> doLogin(String email, String password, bool stayLogged) async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await auth.login(email, password, stayLoggedIn: stayLogged);
      final user = Map<String, dynamic>.from(data['user'] ?? {});
      userType = (user['user_type'] ?? '').toString();
      userSubRole = (user['user_sub_role'] ?? '').toString();
      emailVerified =
          (user['is_email_verified'] ?? (user['email_verified_at'] != null)) ==
          true;
      displayName = _extractName(user);

      // persist name too (other fields are persisted by AuthService)
      final sp = await SharedPreferences.getInstance();
      await sp.setString('display_name', displayName);

      isLoggedIn = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> doLogout() async {
    await auth.logout();
    isLoggedIn = false;
    userType = '';
    userSubRole = '';
    emailVerified = false;
    displayName = '';
    notifyListeners();
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
