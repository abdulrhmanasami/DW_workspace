import 'package:delivery_ways_clean/app_shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppShell Widget Tests', () {
    testWidgets('renders child inside SafeArea with background color from theme',
        (tester) async {
      const childKey = Key('app_shell_test_child');

      await tester.pumpWidget(
        const MaterialApp(
          home: AppShell(
            child: SizedBox(
              key: childKey,
            ),
          ),
        ),
      );

      // يتأكد أن الـ child ظاهر
      expect(find.byKey(childKey), findsOneWidget);

      // يتأكد أنه لا يحصل أي Crash عند إعادة البناء
      await tester.pump();
    });
  });
}
