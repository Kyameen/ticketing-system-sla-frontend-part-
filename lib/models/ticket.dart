class Ticket {
  final int id;
  final String subject;
  final String description;
  final int? priorityId;
  final int? statusId;
  final int? categoryId;
  final int? departmentId;
  final int clientId;
  final int companyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.subject,
    required this.description,
    this.priorityId,
    this.statusId,
    this.categoryId,
    this.departmentId,
    required this.clientId,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> j) {
    DateTime parseDate(String? v) =>
        (v == null || v.isEmpty) ? DateTime.now() : DateTime.parse(v);

    int? parseInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

    return Ticket(
      id: int.parse(j['id'].toString()),
      subject: (j['subject'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      priorityId: parseInt(j['priority_id']),
      statusId: parseInt(j['status_id']),
      categoryId: parseInt(j['category_id']),
      departmentId: parseInt(j['department_id']),
      clientId: int.parse(j['client_id'].toString()),
      companyId: int.parse(j['company_id'].toString()),
      createdAt: parseDate(j['created_at']),
      updatedAt: parseDate(j['updated_at']),
    );
  }
}
