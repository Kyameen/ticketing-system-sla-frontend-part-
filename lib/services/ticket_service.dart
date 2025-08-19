// lib/services/ticket_service.dart
import 'dart:convert';

import '../models/ticket.dart';
import 'api_client.dart';

class TicketService {
  final ApiClient api;
  TicketService(this.api);

  // ---- helpers ----
  Map<String, dynamic> _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _asMap(String body) {
    try {
      return _safeMap(jsonDecode(body));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String? _message(String body) {
    try {
      final m = _asMap(body);
      final v = m['message'];
      return v?.toString();
    } catch (_) {
      return null;
    }
  }

  /// GET tickets visible to the current user.
  /// Always hits `/tickets` and lets the backend scope by role.
  /// [forClient] is kept for backward compatibility but is ignored.
  Future<List<Ticket>> listMine({bool forClient = false}) async {
    const path = '/tickets';

    // DEBUG
    // ignore: avoid_print
    print('[TicketService] GET $path');

    final res = await api.get(path);

    // DEBUG
    // ignore: avoid_print
    print('[TicketService] -> status=${res.statusCode}');
    // ignore: avoid_print
    print('[TicketService] -> body=${res.body}');

    if (res.statusCode ~/ 100 != 2) {
      throw Exception(
        _message(res.body) ?? 'Failed to fetch tickets (${res.statusCode})',
      );
    }

    // Accept either { data: [...] } or a plain [...]
    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (_) {
      decoded = null;
    }

    List<dynamic> rawList;
    if (decoded is List) {
      rawList = decoded;
    } else if (decoded is Map && decoded['data'] is List) {
      rawList = decoded['data'] as List;
    } else {
      rawList = const [];
    }

    // Parse defensively: skip any row that fails to decode.
    final parsed = <Ticket>[];
    for (final e in rawList) {
      if (e is Map) {
        try {
          parsed.add(Ticket.fromJson(Map<String, dynamic>.from(e)));
        } catch (err) {
          // ignore: avoid_print
          print('[TicketService] skip row parse error: $err');
        }
      } else {
        // ignore: avoid_print
        print('[TicketService] skip non-map row: $e');
      }
    }

    // DEBUG
    // ignore: avoid_print
    print('[TicketService] items=${parsed.length}');
    return parsed;
  }

  /// Alias for listMine() — backend scopes by role, so this returns
  /// "all I’m allowed to see" (system/company see all; client_user sees own).
  Future<List<Ticket>> listAll() async {
    return listMine();
  }

  /// POST /tickets — create a ticket
  Future<Ticket> create({
    required String subject,
    required String description,
    int? priorityId,
    int? categoryId,
    int? departmentId,
    int? companyId,
    int? clientId,
  }) async {
    final payload = <String, dynamic>{
      'subject': subject,
      'description': description,
      if (priorityId != null) 'priority_id': priorityId,
      if (categoryId != null) 'category_id': categoryId,
      if (departmentId != null) 'department_id': departmentId,
      if (companyId != null) 'company_id': companyId,
      if (clientId != null) 'client_id': clientId,
    };

    // ApiClient.post expects (path, body)
    final res = await api.post('/tickets', payload);

    // Accept 200/201 as success
    if (res.statusCode != 200 && res.statusCode != 201) {
      final text = (res.bodyBytes.isEmpty) ? '' : utf8.decode(res.bodyBytes);
      try {
        final m = jsonDecode(text);
        final msg = (m is Map && m['message'] is String)
            ? m['message']
            : 'Failed to create ticket';
        throw Exception('HTTP ${res.statusCode}: $msg');
      } catch (_) {
        throw Exception('HTTP ${res.statusCode}: Failed to create ticket');
      }
    }

    // Safely decode body (some servers send empty/`null` body on 201)
    final text = (res.bodyBytes.isEmpty) ? '' : utf8.decode(res.bodyBytes);
    if (text.trim().isEmpty || text.trim() == 'null') {
      // Minimal object; your Ticket.fromJson should tolerate nulls
      return Ticket.fromJson({
        'id': null,
        'subject': subject,
        'description': description,
        'created_at': null,
        'updated_at': null,
      });
    }

    dynamic root;
    try {
      root = jsonDecode(text);
    } catch (_) {
      throw Exception('Invalid server response while creating ticket');
    }

    final data = (root is Map && root['data'] != null) ? root['data'] : root;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected server response while creating ticket');
    }
    return Ticket.fromJson(data);
  }
}
