// lib/screens/tickets/ticket_assignments_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/ticket_provider.dart';
import '../../models/ticket.dart';
import '../../services/api_client.dart';
import '../../services/user_service.dart';
import '../../services/priority_service.dart';

class TicketAssignmentsScreen extends StatefulWidget {
  const TicketAssignmentsScreen({super.key});

  @override
  State<TicketAssignmentsScreen> createState() => _TicketAssignmentsScreenState();
}

class _TicketAssignmentsScreenState extends State<TicketAssignmentsScreen> {
  bool isLoading = true;
  String? error;

  List<Ticket> _tickets = [];
  Map<int, String> _userNameById = {};
  Map<int, String> _priorityNameById = {};

  Future<void> _load() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // 1) Load tickets (backend already scopes by role)
      final prov = context.read<TicketProvider>();
      await prov.loadAll();
      final items = prov.items;

      // 2) Load users & priorities to resolve labels
      final api = ApiClient();
      final users = await UserService(api).listCompanyUsers();
      final prios = await PriorityService(api).listAll();

      setState(() {
        _tickets = items; // we show all; you can filter if you want
        _userNameById = {for (final u in users) u.id: u.name};
        _priorityNameById = {for (final p in prios) p.id: p.name};
      });
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => isLoading = false);
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
                                ? (_userNameById[t.assignedTo!] ?? 'User #${t.assignedTo}')
                                : 'Unassigned';

                            final prio = (t.priorityId != null)
                                ? (_priorityNameById[t.priorityId!] ?? 'Priority #${t.priorityId}')
                                : '—';

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: cs.outlineVariant),
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
                                onTap: () {}, // optional: open ticket details later
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
