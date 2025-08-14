import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService auth;
  AuthProvider(this.auth);

  bool isLoading = false;
  bool isLoggedIn = false;
  String userType = '';
  String userSubRole = '';
  bool emailVerified = false;

  Future<void> init() async {
    isLoggedIn = await auth.loadSavedSession();
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
      isLoggedIn = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> doLogout() async {
    await auth.logout();
    isLoggedIn = false;
    notifyListeners();
  }
}
