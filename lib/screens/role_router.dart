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
    final type = auth.userType; // 'system_admin' | 'company' | 'client'

    if (type == 'client') return const ClientHome();
    return const CompanyHome(); // company & system_admin
  }
}
