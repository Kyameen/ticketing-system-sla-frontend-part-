// lib/services/ticket_message_service.dart
import 'dart:convert';
import 'dart:async';

import '../models/ticket_message.dart';
import 'api_client.dart';

class TicketMessageService {
  final ApiClient api;
  TicketMessageService(this.api);

  Future<List<TicketMessage>> list(int ticketId) async {
    final path = '/tickets/$ticketId/messages';
    // DEBUG
    // ignore: avoid_print
    print('[TicketMessageService] GET $path');

    final res = await api.get(path).timeout(const Duration(seconds: 20));

    // DEBUG
    // ignore: avoid_print
    print('[TicketMessageService] -> status=${res.statusCode}');
    // ignore: avoid_print
    print('[TicketMessageService] -> body=${res.body}');

    if (res.statusCode ~/ 100 != 2) {
      // Propagate a readable error up to the UI
      throw Exception('Failed to fetch messages (${res.statusCode})');
    }

    dynamic root;
    try {
      root = jsonDecode(res.body);
    } catch (_) {
      root = null;
    }

    List raw;
    if (root is List) {
      raw = root;
    } else if (root is Map && root['data'] is List) {
      raw = root['data'];
    } else if (root is Map &&
        root['data'] is Map &&
        (root['data']['messages'] is List)) {
      // tolerate {"data":{"messages":[...]}}
      raw = root['data']['messages'];
    } else {
      raw = const [];
    }

    final out = <TicketMessage>[];
    for (final e in raw) {
      if (e is Map) {
        try {
          out.add(TicketMessage.fromJson(Map<String, dynamic>.from(e)));
        } catch (_) {
          // skip bad rows
        }
      }
    }
    return out;
  }

  Future<TicketMessage> sendText({
    required int ticketId,
    required String message,
  }) async {
    final path = '/tickets/$ticketId/messages';
    final body = {'message': message};

    final res = await api.post(path, body).timeout(const Duration(seconds: 20));

    // DEBUG
    // ignore: avoid_print
    print('[TicketMessageService] POST $path -> ${res.statusCode}');

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to send message (${res.statusCode})');
    }

    dynamic root;
    try {
      root = jsonDecode(res.body);
    } catch (_) {
      root = null;
    }

    final data = (root is Map && root['data'] is Map)
        ? Map<String, dynamic>.from(root['data'])
        : (root is Map<String, dynamic> ? root : <String, dynamic>{});

    return TicketMessage.fromJson(data);
  }
}
