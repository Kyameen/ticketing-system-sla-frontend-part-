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

  /// Load current user's tickets
  Future<void> refresh() async {
    isLoading = true;
    notifyListeners();
    try {
      items = await svc.listMine();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Create a ticket, then prepend to the list
  Future<Ticket> create({
    required String subject,
    required String description,
    int? priorityId,
    int? categoryId,
    int? departmentId,
    int? companyId,
    int? clientId,
  }) async {
    final t = await svc.create(
      subject: subject,
      description: description,
      priorityId: priorityId,
      categoryId: categoryId,
      departmentId: departmentId,
      companyId: companyId,
      clientId: clientId,
    );
    items = [t, ...items];
    notifyListeners();
    return t;
  }
}
