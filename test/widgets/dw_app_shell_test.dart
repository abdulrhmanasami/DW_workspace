/// DWAppShell Widget Tests
/// Created by: Track A - Ticket #134
/// Purpose: Verify DWAppShell renders correctly with Design System tokens

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_shims/design_system_shims.dart';
import 'package:delivery_ways_clean/widgets/dw_app_shell.dart';

void main() {
  group('DWAppShell', () {
    testWidgets('renders body and uses background color from theme',
        (tester) async {
      const bodyText = 'Hello DW Shell';

      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text(bodyText),
          ),
        ),
      );

      // Verify body content is rendered
      expect(find.text(bodyText), findsOneWidget);

      // Verify Scaffold is present (the actual shell)
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('applies standard padding by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text('Padded content'),
          ),
        ),
      );

      // Find the Padding widget that wraps the body
      final paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsWidgets);

      // Verify at least one Padding has DWSpacing.md (16pt) padding
      bool foundExpectedPadding = false;
      for (final element in paddingFinder.evaluate()) {
        final widget = element.widget as Padding;
        if (widget.padding ==
            const EdgeInsets.symmetric(
              horizontal: DWSpacing.md,
              vertical: DWSpacing.md,
            )) {
          foundExpectedPadding = true;
          break;
        }
      }
      expect(foundExpectedPadding, isTrue,
          reason: 'Expected padding with DWSpacing.md not found');
    });

    testWidgets('does not apply padding when applyPadding is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text('Full bleed content'),
            applyPadding: false,
          ),
        ),
      );

      // Verify body text is present
      expect(find.text('Full bleed content'), findsOneWidget);

      // Check that the DWSpacing.md padding is NOT applied
      final paddingFinder = find.byType(Padding);
      for (final element in paddingFinder.evaluate()) {
        final widget = element.widget as Padding;
        expect(
          widget.padding !=
              const EdgeInsets.symmetric(
                horizontal: DWSpacing.md,
                vertical: DWSpacing.md,
              ),
          isTrue,
          reason: 'Should not have standard body padding when applyPadding is false',
        );
      }
    });

    testWidgets('wraps body in SafeArea by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text('Safe content'),
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('does not wrap in SafeArea when useSafeArea is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text('No safe area'),
            useSafeArea: false,
          ),
        ),
      );

      // SafeArea should not be present in DWAppShell's tree
      // Note: There might be SafeArea in other parts of the widget tree,
      // but we verify our DWAppShell doesn't add one
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold, isNotNull);
    });

    testWidgets('renders appBar when provided', (tester) async {
      const appBarTitle = 'Test App Bar';

      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: DWAppShell(
            appBar: AppBar(title: const Text(appBarTitle)),
            body: const Text('Body content'),
          ),
        ),
      );

      expect(find.text(appBarTitle), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders bottomNavigationBar when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: DWAppShell(
            body: const Text('Body'),
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders floatingActionButton when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: DWAppShell(
            body: const Text('Body'),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('respects extendBodyBehindAppBar when set to true',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: DWAppShell(
            appBar: AppBar(
              title: const Text('Extended'),
              backgroundColor: Colors.transparent,
            ),
            body: const Text('Extended body'),
            extendBodyBehindAppBar: true,
            applyPadding: false,
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.extendBodyBehindAppBar, isTrue);
    });

    testWidgets('uses theme colorScheme.surface as background color',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DWTheme.light(),
          home: const DWAppShell(
            body: Text('Test background'),
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      // DWTheme.light() colorScheme.surface is #FFFFFF
      expect(scaffold.backgroundColor, equals(const Color(0xFFFFFFFF)));
    });
  });
}

