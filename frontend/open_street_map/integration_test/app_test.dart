import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_map/flutter_map.dart'; // ✅ Required for FlutterMap widget
import 'package:open_street_map/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login and navigate to Assigned Routes', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ✅ Adjust these texts if you use .tr()
    expect(find.text('Welcome Back'), findsOneWidget);

    // Enter login
    await tester.enterText(find.byType(TextField).at(0), 'courier@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.byType(Scaffold), findsWidgets);

    // Open drawer
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    // Tap Assigned Routes
    await tester.tap(find.text('Assigned Routes'));
    await tester.pumpAndSettle();

    expect(find.text('Assigned Routes'), findsOneWidget); // Localized

    // Tap first route
    await tester.tap(find.byType(ListTile).first);
    await tester.pumpAndSettle();

    // Start navigation
    await tester.tap(find.byIcon(Icons.navigation));
    await tester.pumpAndSettle();

    // Verify FlutterMap loaded
    expect(find.byType(FlutterMap), findsOneWidget);
  });
}
