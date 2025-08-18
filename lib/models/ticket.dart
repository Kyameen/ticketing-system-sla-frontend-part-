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

  final int? assignedTo; // NEW
  final int? createdBy; // NEW

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
    this.assignedTo, // NEW
    this.createdBy, // NEW
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
      assignedTo: toInt(j['assigned_to']), // NEW
      createdBy: toInt(j['created_by']), // NEW
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
    'assigned_to': assignedTo, // NEW
    'created_by': createdBy, // NEW
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
