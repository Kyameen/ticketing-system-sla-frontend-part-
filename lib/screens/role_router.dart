import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'client_home.dart';
import 'company_home.dart';

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // userType is non-nullable in AuthProvider, so no need for ??
    final type = auth.userType
        .toLowerCase(); // 'system_admin' | 'company' | 'client'

    switch (type) {
      case 'client':
        return const ClientHomeScreen();
      case 'company':
      case 'system_admin': // not in MVP; reuse company shell
      default:
        return const CompanyHomeScreen();
    }
  }
}
