import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';

class RoleChrome extends StatelessWidget {
  final Widget child;
  const RoleChrome({super.key, required this.child});

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    final p = s.replaceAll('_', ' ').split(' ');
    return p
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final crumb = [
      if (auth.userType.isNotEmpty) _titleCase(auth.userType),
      if (auth.userSubRole.isNotEmpty) _titleCase(auth.userSubRole),
    ].join(' • ');

    final greetName = (auth.displayName.isNotEmpty) ? auth.displayName : 'User';

    return Column(
      children: [
        // HEADER
        Material(
          color: Colors.transparent,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $greetName',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          crumb,
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logout
                  OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().doLogout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ),

        // CONTENT
        Expanded(child: child),

        // FOOTER crumb
        Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Chip(
                  label: Text(crumb.isEmpty ? 'Ticketing System' : crumb),
                  labelStyle: tt.labelSmall?.copyWith(
                    color: cs.onSecondaryContainer,
                  ),
                  backgroundColor: cs.secondaryContainer.withAlpha(230),
                  shape: const StadiumBorder(),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
