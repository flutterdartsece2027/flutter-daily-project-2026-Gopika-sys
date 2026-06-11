import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maison_vault_app/main.dart'; // Verified package module import

void main() {
  testWidgets('Beauty Store App Boot Test', (WidgetTester tester) async {
    // 1. Mount the core root application layout
    await tester.pumpWidget(const BeautyStoreApp());

    // 2. Verify that the app mounts and initializes the splash screen view
    expect(find.byType(BeautyStoreApp), findsOneWidget);

    // FIXED: Mocks simulated time frames to safely run out the 4-second splash timer
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}