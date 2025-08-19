// lib/services/user_service.dart
import 'dart:convert';
import 'api_client.dart';

class UserLite {
  final int id;
  final String name;
  final String? userType; // 'company', 'client', 'system_admin', ...
  final String? userSubRole; // 'User', 'Manager', ...

  UserLite({
    required this.id,
    required this.name,
    this.userType,
    this.userSubRole,
  });
}

class UserService {
  final ApiClient api;
  UserService(this.api);

  Future<List<UserLite>> listCompanyUsers() async {
    // Adjust path if your API uses a different users endpoint
    final res = await api.get('/users');

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Failed to load users (${res.statusCode})');
    }

    dynamic root;
    try {
      root = jsonDecode(res.body);
    } catch (_) {
      throw Exception('Invalid server response for users');
    }

    final list = (root is Map && root['data'] is List)
        ? root['data'] as List
        : (root as List? ?? const []);
    return list
        .map((e) {
          final m = (e is Map) ? e : <String, dynamic>{};
          final id = (m['id'] ?? m['user_id']) as int?;
          final name = (m['name'] ?? m['full_name'] ?? m['email'] ?? 'Unknown')
              .toString();
          final ut = (m['user_type'] is Map)
              ? m['user_type']['type']?.toString()
              : m['user_type']?.toString();
          final sr = (m['user_sub_role'] is Map)
              ? m['user_sub_role']['sub_type']?.toString()
              : m['user_sub_role']?.toString();

          return UserLite(
            id: id ?? -1,
            name: name,
            userType: ut,
            userSubRole: sr,
          );
        })
        .where((u) => u.id != -1)
        .toList();
  }
}
