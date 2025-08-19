// lib/providers/ticket_provider.dart
import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';
import 'auth_provider.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService svc;
  final AuthProvider auth;

  TicketProvider(this.svc, this.auth);

  bool isLoading = false;
  List<Ticket> items = [];

  /// Refresh helper:
  /// - `refresh()` behaves like your old method (loads "mine").
  /// - `refresh(onlyMine: true)` -> load only my tickets.
  /// - `refresh(onlyMine: false)` -> load all tickets allowed by role.
  Future<void> refresh({bool? onlyMine}) {
    if (onlyMine == null) return loadMine();
    return onlyMine ? loadMine() : loadAll();
  }

  /// Load all tickets allowed by the current role (backend enforces scope).
  Future<void> loadAll() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      // Server returns ALL (for system/company admin/manager) or scoped set per role.
      items = await svc.listAll();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Load only tickets relevant to the current user.
  /// - Company · User  -> trust backend (server already returns only "my" tickets)
  /// - Client  · User  -> server scopes; also guard client-side by created_by == me
  /// - Others          -> same as loadAll
  Future<void> loadMine() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final type = auth.userType;
      final sub = auth.userSubRole;

      // Company · User: don't apply any client-side filter.
      if (type == 'company' && sub == 'User') {
        items = await svc.listAll();
        return;
      }

      // Client · User: keep server scope and apply a safe guard (created_by == me).
      if (type == 'client' && sub == 'client_user') {
        final all = await svc.listAll();
        final uid = auth.userId;
        items = all.where((t) => t.createdBy == uid).toList();
        return;
      }

      // Others: fallback to all (server may scope by role)
      items = await svc.listAll();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Create a ticket, then prepend to the list.
  Future<Ticket> create({
    required String subject,
    required String description,
    int? priorityId,
    int? categoryId,
    int? departmentId,
    int? companyId,
    int? clientId,
  }) async {
    if (isLoading) throw Exception('Already creating a ticket');
    isLoading = true;
    notifyListeners();

    try {
      final t = await svc.create(
        subject: subject,
        description: description,
        priorityId: priorityId,
        categoryId: categoryId,
        departmentId: departmentId,
        companyId: companyId,
        clientId: clientId,
      );
      // show new ticket immediately at the top
      items = [t, ...items];
      notifyListeners();
      return t;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
