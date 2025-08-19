// lib/services/priority_service.dart
import 'dart:convert';
import 'api_client.dart';

class PriorityLite {
  final int id;
  final String name;

  PriorityLite({required this.id, required this.name});
}

class PriorityService {
  final ApiClient api;
  PriorityService(this.api);

  Future<List<PriorityLite>> listAll() async {
    // Adjust the path if your API uses a different endpoint
    final res = await api.get('/priorities');

    if (res.statusCode ~/ 100 != 2) {
      throw Exception('Failed to load priorities (${res.statusCode})');
    }

    dynamic root;
    try {
      root = jsonDecode(res.body);
    } catch (_) {
      throw Exception('Invalid server response for priorities');
    }

    final list = (root is Map && root['data'] is List)
        ? root['data'] as List
        : (root as List? ?? const []);
    return list
        .map((e) {
          final m = (e is Map) ? e : <String, dynamic>{};
          final id = m['id'] as int?;
          final name = (m['name'] ?? m['title'] ?? 'Priority').toString();
          return PriorityLite(id: id ?? -1, name: name);
        })
        .where((p) => p.id != -1)
        .toList();
  }
}
