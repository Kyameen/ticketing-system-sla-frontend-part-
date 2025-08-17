// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ticketing_mvp/main.dart'; // <-- if your pubspec name differs, fix this line
import 'package:ticketing_mvp/services/api_client.dart';
import 'package:ticketing_mvp/services/auth_service.dart';
import 'package:ticketing_mvp/services/ticket_service.dart';

void main() {
  testWidgets('app builds', (WidgetTester tester) async {
    final api = ApiClient();
    final authService = AuthService(api);
    final ticketService = TicketService(api);

    await tester.pumpWidget(
      MyApp(api: api, authService: authService, ticketService: ticketService),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
