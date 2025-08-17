// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/ticket_service.dart';

import 'providers/auth_provider.dart';
import 'providers/ticket_provider.dart';

import 'screens/login_screen.dart';
import 'screens/role_router.dart';
import 'widgets/role_chrome.dart';

void main() {
  final api = ApiClient();
  final authService = AuthService(api);
  final ticketService = TicketService(api);

  runApp(
    MyApp(api: api, authService: authService, ticketService: ticketService),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient api;
  final AuthService authService;
  final TicketService ticketService;

  const MyApp({
    super.key,
    required this.api,
    required this.authService,
    required this.ticketService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (ctx) =>
              TicketProvider(ticketService, ctx.read<AuthProvider>()),
        ),
      ],
      child: const _AppShell(),
    );
  }
}

/// Show UI immediately; kick off auth.init() once, synchronously.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  @override
  void initState() {
    super.initState();
    // Allowed by Provider in initState: read without listening.
    final auth = context.read<AuthProvider>();
    // Fire-and-forget; provider will notify listeners when done.
    auth.init();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticketing System MVP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A6CF7)),
        useMaterial3: true,
      ),
      // Wrap logged-in pages with RoleChrome
      builder: (context, child) {
        final w = child ?? const SizedBox.shrink();
        if (!auth.isLoggedIn) return w;
        return RoleChrome(child: w);
      },
      // Decide screen from current auth state (no FutureBuilder, no spinner)
      home: auth.isLoggedIn ? const RoleRouter() : const LoginScreen(),
    );
  }
}
