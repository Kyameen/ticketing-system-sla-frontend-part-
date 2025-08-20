// lib/models/ticket_message.dart
class TicketMessage {
  final int? id;
  final int? ticketId;
  final int? userId;
  final String message;
  final String? image; // relative path (if any)
  final String? imageUrl; // absolute url (if API returns image_url)
  final DateTime? createdAt;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    this.image,
    this.imageUrl,
    this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> j) {
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

    return TicketMessage(
      id: toInt(j['id']),
      ticketId: toInt(j['ticket_id']),
      userId: toInt(j['user_id'] ?? j['created_by']),
      message: (j['message'] ?? '').toString(),
      image: (() {
        final v = j['image'];
        if (v == null) return null;
        final s = v.toString();
        return s.isEmpty ? null : s;
      })(),
      imageUrl: (() {
        final v = j['image_url'];
        if (v == null) return null;
        final s = v.toString();
        return s.isEmpty ? null : s;
      })(),
      createdAt: toDate(j['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket_id': ticketId,
    'user_id': userId,
    'message': message,
    'image': image,
    'image_url': imageUrl,
    'created_at': createdAt?.toIso8601String(),
  };
}
