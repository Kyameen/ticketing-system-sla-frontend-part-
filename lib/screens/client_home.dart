// lib/screens/client_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/role_policy.dart';
import '../widgets/home_action_button.dart';

import 'tickets/ticket_list_screen.dart';
import 'tickets/create_ticket_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  void _msg(BuildContext context, String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final policy = RolePolicy(type: auth.userType, sub: auth.userSubRole);

    final actions = <Widget>[];

    // ----- Client User actions -----
    if (policy.isClientUser) {
      // Create Ticket
      actions.add(
        HomeActionButton(
          icon: Icons.add_circle_outline,
          label: 'Create Ticket',
          onTap: () async {
            final messenger = ScaffoldMessenger.of(
              context,
            ); // capture before await
            final created = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
            );
            if (created == true) {
              messenger.showSnackBar(
                const SnackBar(content: Text('Ticket created')),
              );
            }
          },
        ),
      );

      // My Tickets (only tickets created by this user)
      actions.add(
        HomeActionButton(
          icon: Icons.inbox_outlined,
          label: 'My Tickets',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TicketListScreen(
                  assignedToMe: true, // show only my tickets
                ),
              ),
            );
          },
        ),
      );
    }

    // ----- Client Manager actions -----
    if (policy.isClientManager) {
      // All client-team tickets (you can wire backend filter later)
      actions.add(
        HomeActionButton(
          icon: Icons.list_alt_outlined,
          label: 'Tickets (client)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TicketListScreen(
                  createdByClientTeam: true, // safe even if ignored for now
                ),
              ),
            );
          },
        ),
      );

      // Client manager's own tickets
      actions.add(
        HomeActionButton(
          icon: Icons.person_outline,
          label: 'My Tickets',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TicketListScreen(
                  assignedToMe: true, // only my tickets
                ),
              ),
            );
          },
        ),
      );
    }

    // Fallback when no actions available
    if (actions.isEmpty) {
      actions.add(
        HomeActionButton(
          icon: Icons.info_outline,
          label: 'No actions for this role',
          onTap: () => _msg(context, 'No actions available'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Client Home')),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: actions,
      ),
    );
  }
}
