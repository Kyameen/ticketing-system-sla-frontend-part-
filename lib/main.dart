import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/role_router.dart';

void main() {
  // Build our service graph
  final api = ApiClient();
  final authService = AuthService(api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ticketing MVP',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo, // subtle brand color
      ),
      home: FutureBuilder(
        future: auth.init(), // load saved token if any
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If logged in → go to role router, else → login
          return auth.isLoggedIn ? const RoleRouter() : const LoginScreen();
        },
      ),
    );
  }
}
