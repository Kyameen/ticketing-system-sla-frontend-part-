import 'dart:convert';

import '../models/ticket.dart';
import 'api_client.dart';

class TicketService {
  final ApiClient api;
  TicketService(this.api);

  // -------- helpers --------
  Map<String, dynamic> _asMap(String body) {
    final d = jsonDecode(body);
    return d is Map ? d.cast<String, dynamic>() : <String, dynamic>{};
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

  // GET tickets visible to the current user.
  // If your backend uses a dedicated route for clients, tweak the path below.
  // Example alternatives:
  //   final path = forClient ? '/tickets/mine' : '/tickets';
  Future<List<Ticket>> listMine({bool forClient = false}) async {
    final path = forClient ? '/tickets?mine=1' : '/tickets';
    final res = await api.get(path);

    if (res.statusCode ~/ 100 != 2) {
      throw Exception(
        _message(res.body) ?? 'Failed to fetch tickets (${res.statusCode})',
      );
    }

    final map = _asMap(res.body);
    final list = (map['data'] as List?) ?? const [];
    return list
        .map((e) => Ticket.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  // POST /tickets — create a ticket
  Future<Ticket> create({
    required String subject,
    required String description,
    int? priorityId,
    int? categoryId,
    int? departmentId,
    // For client users company_id/client_id are injected on backend.
    int? companyId,
    int? clientId,
    int? agreementId, // keep if your server needs it; otherwise safe to ignore
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'description': description,
      if (priorityId != null) 'priority_id': priorityId,
      if (categoryId != null) 'category_id': categoryId,
      if (departmentId != null) 'department_id': departmentId,
      if (companyId != null) 'company_id': companyId,
      if (clientId != null) 'client_id': clientId,
      if (agreementId != null) 'agreement_id': agreementId,
    };

    final res = await api.post('/tickets', body);

    if (res.statusCode ~/ 100 != 2) {
      throw Exception(
        _message(res.body) ?? 'Create ticket failed (${res.statusCode})',
      );
    }

    final map = _asMap(res.body);
    final data = (map['data'] is Map)
        ? (map['data'] as Map).cast<String, dynamic>()
        : <String, dynamic>{};
    return Ticket.fromJson(data);
  }
}
