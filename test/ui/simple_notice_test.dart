import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:design_system_shims/design_system_shims.dart';
import '../support/app_harness.dart';

void main() {
  setUp(() {
    AppTestHarness.reset();
  });

  testWidgets('Basic notice display works', (tester) async {
    await tester.pumpWidget(
      AppTestHarness.makeTestApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              final presenter = capturingNoticePresenter;
              presenter.show(
                AppNotice.info(
                  message: 'Hello from test!',
                ),
              );
            },
            child: const Text('Show Notice'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Notice'));
    await tester.pumpAndSettle();

    expect(capturingNoticePresenter.wasCalled, isTrue);
    expect(capturingNoticePresenter.lastNotice?.message, 'Hello from test!');
  });
}
