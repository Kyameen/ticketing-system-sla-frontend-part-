// lib/screens/tickets/ticket_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../models/ticket.dart';

class TicketListScreen extends StatefulWidget {
  /// Optional flags (for future filtering; safe even if provider/model
  /// doesn’t support these yet)
  final bool showUnassignedOnly; // Manager: assign unassigned
  final bool assignedToMe; // Company User: my tickets
  final bool createdByClientTeam; // Client Manager: tickets by client users

  const TicketListScreen({
    super.key,
    this.showUnassignedOnly = false,
    this.assignedToMe = false,
    this.createdByClientTeam = false,
  });

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TicketProvider>().refresh();
    });
  }

  String _title() {
    if (widget.assignedToMe) return 'My Tickets';
    if (widget.showUnassignedOnly) return 'Unassigned Tickets';
    if (widget.createdByClientTeam) return 'Client Tickets';
    return 'Tickets';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<TicketProvider>();
    final items = prov.items; // We’ll add real filtering later at provider/API.

    final hasFilter =
        widget.assignedToMe ||
        widget.showUnassignedOnly ||
        widget.createdByClientTeam;

    return Scaffold(
      appBar: AppBar(title: Text(_title())),
      body: Column(
        children: [
          if (hasFilter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.6,
                  ),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: -6,
                children: [
                  if (widget.assignedToMe)
                    const _FilterChipLabel(text: 'assigned_to_me'),
                  if (widget.showUnassignedOnly)
                    const _FilterChipLabel(text: 'unassigned_only'),
                  if (widget.createdByClientTeam)
                    const _FilterChipLabel(text: 'client_team'),
                  const _FilterChipLabel(text: 'UI filter only (MVP step)'),
                ],
              ),
            ),
          Expanded(
            child: prov.isLoading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: prov.refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (_, i) => _TicketTile(items[i]),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: items.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipLabel extends StatelessWidget {
  final String text;
  const _FilterChipLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TicketTile extends StatelessWidget {
  final Ticket t;
  const _TicketTile(this.t);

  @override
  Widget build(BuildContext context) {
    final sub = TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Card(
      child: ListTile(
        title: Text(t.subject),
        subtitle: Text(
          t.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: sub,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (t.statusId != null) Text('Status: ${t.statusId}', style: sub),
            Text('ID: ${t.id}', style: sub),
          ],
        ),
      ),
    );
  }
}
