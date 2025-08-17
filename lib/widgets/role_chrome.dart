// lib/widgets/role_chrome.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RoleChrome extends StatelessWidget {
  final Widget child;
  const RoleChrome({super.key, required this.child});

  String _titleCase(String s) {
    if (s.isEmpty) return s;
    final p = s.replaceAll('_', ' ').split(' ');
    return p
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final greetName = auth.displayName.isNotEmpty
        ? auth.displayName
        : _titleCase(auth.userSubRole);

    final crumb =
        '${_titleCase(auth.userType)} / ${_titleCase(auth.userSubRole)}';

    return Column(
      children: [
        // HEADER
        Material(
          elevation: 1,
          color: cs.surface,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.badge,
                      color: cs.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name — normal title size
                        Text(
                          'Hello, $greetName',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        // Small secondary line (role crumb)
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
                  // Logout — compact outlined button, top-right
                  OutlinedButton.icon(
                    onPressed: () => context.read<AuthProvider>().doLogout(),
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

        // FOOTER CRUMB — subtle chip centered, wrapped in Material to provide a Material ancestor
        Material(
          color: Colors.transparent,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Chip(
                  label: Text(crumb, style: tt.labelMedium),
                  avatar: Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: cs.onSecondaryContainer,
                  ),
                  // use opacity (0..1), not withAlpha(800)
                  backgroundColor: cs.secondaryContainer.withAlpha(850),
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
