// lib/screens/tickets/ticket_assignments_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ticket_provider.dart';
import '../../models/ticket.dart';

class TicketAssignmentsScreen extends StatefulWidget {
  const TicketAssignmentsScreen({super.key});

  @override
  State<TicketAssignmentsScreen> createState() =>
      _TicketAssignmentsScreenState();
}

class _TicketAssignmentsScreenState extends State<TicketAssignmentsScreen> {
  bool isLoading = true;
  String? error;

  List<Ticket> _tickets = [];

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final prov = context.read<TicketProvider>();
      await prov.loadAll();
      final items = prov.items;

      // You can filter here if you later add `assignedBy` to the Ticket model:
      // final myId = context.read<AuthProvider>().userId;
      // final mine = items.where((t) => t.assignedBy == myId).toList();

      setState(() {
        _tickets = items;
      });
    } catch (e) {
      setState(() => error = 'Failed to load tickets: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Assignments')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : RefreshIndicator(
              onRefresh: _load,
              child: _tickets.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No tickets to show')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final t = _tickets[i];

                        final assignee = (t.assignedTo != null)
                            ? 'User #${t.assignedTo}'
                            : 'Unassigned';

                        final prio = (t.priorityId != null)
                            ? 'Priority #${t.priorityId}'
                            : '—';

                        return Card(
                          color: cs.surfaceContainerHigh,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            title: Text(t.subject),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Assigned to: $assignee',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                                Text(
                                  'Priority: $prio',
                                  style: TextStyle(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Optional: push ticket detail if you want
                              // Navigator.push(...);
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
