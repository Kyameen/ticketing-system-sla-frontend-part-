// lib/screens/company_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/role_policy.dart';
import '../widgets/home_action_button.dart';
import 'tickets/ticket_assignments_screen.dart';

// Screens you already have:
import 'tickets/ticket_list_screen.dart';

class CompanyHomeScreen extends StatelessWidget {
  const CompanyHomeScreen({super.key});

  void _comingSoon(BuildContext context, String what) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$what — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final policy = RolePolicy(type: auth.userType, sub: auth.userSubRole);

    final actions = <Widget>[];

    // Common: view tickets
    actions.add(
      HomeActionButton(
        icon: Icons.list_alt_outlined,
        label: 'Tickets',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TicketListScreen()),
          );
        },
      ),
    );

    if (policy.isCompanyAdmin) {
      actions.addAll([
        HomeActionButton(
          icon: Icons.group_outlined,
          label: 'Users (mine)',
          onTap: () => _comingSoon(context, 'Users list'),
        ),
        HomeActionButton(
          icon: Icons.assignment_ind_outlined,
          label: 'Ticket Assignments',
          onTap: () => _comingSoon(context, 'Assignments list'),
        ),
        HomeActionButton(
          icon: Icons.description_outlined,
          label: 'Create Agreement',
          onTap: () => _comingSoon(context, 'Create Agreement'),
        ),
      ]);
    }

    if (policy.isCompanyManager) {
      actions.add(
        HomeActionButton(
          icon: Icons.assignment_ind_outlined,
          label: 'Ticket Assignments',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TicketAssignmentsScreen(),
              ),
            );
          },
        ),
      );
    }

    if (policy.isCompanyUser) {
      actions.add(
        HomeActionButton(
          icon: Icons.inbox_outlined,
          label: 'My Tickets',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TicketListScreen(assignedToMe: true),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Company Home')),
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
