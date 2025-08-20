// lib/screens/tickets/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/ticket.dart';
import '../../models/ticket_message.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart'; // to reach ApiClient via svc.api
import '../../services/ticket_message_service.dart';
import '../../utils/role_policy.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late final TicketMessageService _svc;
  late final int _ticketId;
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  bool _loading = true;
  bool _sending = false;
  List<TicketMessage> _items = [];

  @override
  void initState() {
    super.initState();
    _ticketId = widget.ticket.id ?? -1;
    // Reuse ApiClient via TicketProvider
    final api = context.read<TicketProvider>().svc.api;
    _svc = TicketMessageService(api);

    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final msgs = await _svc.list(_ticketId);
      setState(() => _items = msgs);
      _jumpToBottom();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final m = await _svc.sendText(ticketId: _ticketId, message: text);
      setState(() {
        _items = [..._items, m];
        _controller.clear();
      });
      _jumpToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _jumpToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  /// Keep this aligned with your RolePolicy. We only use getters that exist.
  bool _canSend(RolePolicy policy) {
    return policy.isClientUser ||
        policy.isClientManager ||
        policy.isCompanyAdmin ||
        policy.isCompanyManager ||
        policy.isCompanyUser;
    // System roles: backend already enforces; if you want to allow in app later,
    // add the proper RolePolicy getters and extend this condition.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final policy = RolePolicy(type: auth.userType, sub: auth.userSubRole);
    final me = auth.userId;

    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket.subject)),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final m = _items[i];
                        final mine = (m.userId == me);

                        final bubbleColor = mine
                            ? Theme.of(context).colorScheme.primary.withValues(
                                alpha: 0.12,
                              ) // avoids withOpacity lint
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest;

                        final bubble = Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 420),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                              width: 0.6,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: mine
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              if (m.message.isNotEmpty) Text(m.message),
                              if (m.imageUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Image.network(
                                    m.imageUrl!,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (m.createdAt != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    m.createdAt!
                                        .toLocal()
                                        .toString()
                                        .split('.')
                                        .first,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            mainAxisAlignment: mine
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [bubble],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (_canSend(policy))
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'Write a message…',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _sending ? null : _send,
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
