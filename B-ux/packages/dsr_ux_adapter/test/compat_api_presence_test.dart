import 'package:dsr_ux_adapter/dsr_ux_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// API Presence Test - Compile-only test to verify compatibility layer APIs
/// Ensures that all expected getters, constructors, and methods are available
/// This test will fail to compile if any expected API is missing

void main() {
  group('DSR UX Adapter - API Presence Tests', () {
    test('Legacy App* Components are available', () {
      // Test AppButton constructors
      expect(
        () => AppButton.primary(label: 'Test', onPressed: () {}),
        returnsNormally,
      );
      expect(
        () => AppButton.secondary(label: 'Test', onPressed: () {}),
        returnsNormally,
      );

      // Test AppCard constructor
      expect(() => AppCard.standard(child: const SizedBox()), returnsNormally);
    });

    test('DsrColors getters are available', () {
      // Test all expected color getters
      expect(DsrColors.primary, isA<Color>());
      expect(DsrColors.surface, isA<Color>());
      expect(DsrColors.surfaceMuted, isA<Color>());
      expect(DsrColors.onSurface, isA<Color>());
      expect(DsrColors.card, isA<Color>());
      expect(DsrColors.divider, isA<Color>());
      expect(DsrColors.primaryDark, isA<Color>());
      expect(DsrColors.success, isA<Color>());
      expect(DsrColors.warning, isA<Color>());
      expect(DsrColors.error, isA<Color>());
    });

    test('DsrTypography getters are available', () {
      // Test all expected typography getters
      expect(DsrTypography.headlineLarge, isA<TextStyle>());
      expect(DsrTypography.headlineMedium, isA<TextStyle>());
      expect(DsrTypography.titleMedium, isA<TextStyle>());
      expect(DsrTypography.bodyLarge, isA<TextStyle>());
      expect(DsrTypography.bodyMedium, isA<TextStyle>());
      expect(DsrTypography.bodySmall, isA<TextStyle>());
    });

    test('DsrSpacing getters are available', () {
      // Test all expected spacing getters
      expect(DsrSpacing.xxs, isA<double>());
      expect(DsrSpacing.xs, isA<double>());
      expect(DsrSpacing.sm, isA<double>());
      expect(DsrSpacing.md, isA<double>());
      expect(DsrSpacing.lg, isA<double>());
      expect(DsrSpacing.xl, isA<double>());
      expect(DsrSpacing.xxl, isA<double>());
    });

    test('DsrSpacing methods are available', () {
      // Test spacing utility methods
      expect(DsrSpacing.all(8.0), isA<EdgeInsets>());
      expect(
        DsrSpacing.symmetric(horizontal: 8.0, vertical: 4.0),
        isA<EdgeInsets>(),
      );
      expect(DsrSpacing.only(left: 8.0, top: 4.0), isA<EdgeInsets>());
    });

    test('registerUxOverrides function exists', () {
      // Test that registerUxOverrides function is available and callable
      expect(() => registerUxOverrides(), returnsNormally);

      // Test idempotency - calling multiple times should be safe
      expect(() => registerUxOverrides(), returnsNormally);
      expect(() => registerUxOverrides(), returnsNormally);
    });

    test('DwText and DwTextVariant are available', () {
      // Test DwText widget constructor
      expect(() => const DwText('test'), returnsNormally);
      expect(
        () => const DwText('test', variant: DwTextVariant.body),
        returnsNormally,
      );

      // Test DwTextVariant enum values
      expect(DwTextVariant.headlineLarge, isA<DwTextVariant>());
      expect(DwTextVariant.body, isA<DwTextVariant>());
      expect(DwTextVariant.caption, isA<DwTextVariant>());
    });
  });
}
