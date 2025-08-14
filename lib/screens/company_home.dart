import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class CompanyHome extends StatelessWidget {
  const CompanyHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isManagerOrAdmin =
        auth.userSubRole == 'Manager' || auth.userSubRole == 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Company'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().doLogout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: ListTile(
                    title: Text(
                      'Hello, ${auth.userType} (${auth.userSubRole})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: const Text('Quick actions'),
                    leading: const Icon(Icons.apartment),
                  ),
                ),
                const SizedBox(height: 16),
                // Quick actions grid
                LayoutBuilder(
                  builder: (context, c) {
                    final cols = c.maxWidth > 720
                        ? 3
                        : (c.maxWidth > 480 ? 2 : 1);
                    return GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: cols,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _ActionCard(
                          icon: Icons.add_circle,
                          label: 'Create Ticket',
                          onTap: () => _soon(context, 'Create Ticket'),
                        ),
                        _ActionCard(
                          icon: Icons.list_alt,
                          label: 'My Tickets',
                          onTap: () => _soon(context, 'My Tickets'),
                        ),
                        _ActionCard(
                          icon: Icons.group,
                          label: 'Clients',
                          onTap: () => _soon(context, 'Clients'),
                        ),
                        if (isManagerOrAdmin)
                          _ActionCard(
                            icon: Icons.assignment_ind,
                            label: 'Assign Tickets',
                            onTap: () => _soon(context, 'Assign Tickets'),
                          ),
                        if (isManagerOrAdmin)
                          _ActionCard(
                            icon: Icons.settings,
                            label: 'Company Settings',
                            onTap: () => _soon(context, 'Company Settings'),
                          ),
                        _ActionCard(
                          icon: Icons.support_agent,
                          label: 'Support',
                          onTap: () => _soon(context, 'Support'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _soon(BuildContext context, String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$title — coming next')));
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: cs.primary),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
