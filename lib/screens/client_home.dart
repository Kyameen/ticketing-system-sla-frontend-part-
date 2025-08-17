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

    if (policy.isClientUser) {
      actions.add(
        HomeActionButton(
          icon: Icons.add_circle_outline,
          label: 'Create Ticket',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateTicketScreen()),
            );
          },
        ),
      );
    }

    if (policy.isClientManager) {
      actions.add(
        HomeActionButton(
          icon: Icons.list_alt_outlined,
          label: 'Tickets (client)',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TicketListScreen(
                  createdByClientTeam:
                      true, // optional flag (safe even if ignored)
                ),
              ),
            );
          },
        ),
      );
    }

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
