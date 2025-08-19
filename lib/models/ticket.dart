// lib/models/ticket.dart

class Ticket {
  final int? id;
  final String subject;
  final String description;

  final int? priorityId;
  final int? statusId;
  final int? categoryId;
  final int? departmentId;

  final int? clientId;
  final int? companyId;

  /// Assignee user id (company user)
  final int? assignedTo;

  /// Creator user id (client user)
  final int? createdBy;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ticket({
    required this.id,
    required this.subject,
    required this.description,
    this.priorityId,
    this.statusId,
    this.categoryId,
    this.departmentId,
    this.clientId,
    this.companyId,
    this.assignedTo,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    // Robust: assigned_to can be an int, a relation map, or hidden under latest_assignment.agent_id
    int? parseAssignedTo(Map<String, dynamic> m) {
      final direct = m['assigned_to'];
      if (direct is int || direct is String) {
        final v = toInt(direct);
        if (v != null) return v;
      }
      if (direct is Map) {
        final v = toInt(direct['id']);
        if (v != null) return v;
      }
      final la = m['latest_assignment'];
      if (la is Map) {
        final v = toInt(la['agent_id']);
        if (v != null) return v;
      }
      // occasional alternative keys seen in some APIs
      final assignee = m['assignee'];
      if (assignee is Map) {
        final v = toInt(assignee['id']);
        if (v != null) return v;
      }
      return null;
    }

    return Ticket(
      id: toInt(j['id']),
      subject: (j['subject'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      priorityId: toInt(j['priority_id']),
      statusId: toInt(j['status_id']),
      categoryId: toInt(j['category_id']),
      departmentId: toInt(j['department_id']),
      clientId: toInt(j['client_id']),
      companyId: toInt(j['company_id']),
      assignedTo: parseAssignedTo(j),
      createdBy: toInt(j['created_by']),
      createdAt: toDate(j['created_at']),
      updatedAt: toDate(j['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'description': description,
    'priority_id': priorityId,
    'status_id': statusId,
    'category_id': categoryId,
    'department_id': departmentId,
    'client_id': clientId,
    'company_id': companyId,
    'assigned_to': assignedTo,
    'created_by': createdBy,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
