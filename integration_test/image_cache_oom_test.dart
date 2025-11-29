/// Integration test for ImageCache OOM prevention
/// BL-102-004: ImageCache OOM mitigation test
/// Component: ImageCache OOM Test
/// Created by: Cursor (auto-generated)
/// Purpose: Verify ImageCache limits prevent memory leaks
/// Last updated: 2025-11-04

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_shims/foundation_shims.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ImageCache OOM Prevention', () {
    setUpAll(() async {
      // Initialize ImageCache manager
      ImageCacheManager.initialize();

      // Ensure we have a valid binding
      WidgetsFlutterBinding.ensureInitialized();
    });

    tearDownAll(() {
      ImageCacheManager.dispose();
    });

    testWidgets('ImageCache respects size limits', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Get initial cache stats
      final initialStats = ImageCacheManager.getCacheStats();

      expect(initialStats['maximumSize'], equals(50));
      expect(initialStats['maximumSizeBytes'], equals(50 * 1024 * 1024));

      // Verify cache is initialized
      expect(initialStats['isInitialized'], isTrue);
    });

    testWidgets('ImageCache periodic cleanup works', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Wait for periodic cleanup (this test may take some time)
      await Future.delayed(const Duration(seconds: 1));

      // Get cache stats after potential cleanup
      final stats = ImageCacheManager.getCacheStats();

      // Cache should still be within limits
      expect(stats['currentSize'], lessThanOrEqualTo(50));
      expect(stats['currentSizeBytes'], lessThanOrEqualTo(50 * 1024 * 1024));
    });

    testWidgets('ImageCache handles memory pressure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Simulate memory pressure (this would normally be triggered by the system)
      // We can't directly trigger onMemoryPressure, but we can test the cleanup method
      await tester.runAsync(() async {
        // This should not throw any errors
        ImageCacheManager.dispose();
        ImageCacheManager.initialize();
      });

      final afterStats = ImageCacheManager.getCacheStats();

      // Cache should be reinitialized properly
      expect(afterStats['isInitialized'], isTrue);
      expect(afterStats['maximumSize'], equals(50));
    });

    testWidgets('loadResizedImage handles large images safely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Create a test image provider (using a small test image)
      // In a real scenario, this would be a large image from network
      final testImage = await createTestImage(100, 100, Colors.red);

      try {
        // Test resizing a small image (should return as-is)
        final resizedImage = await ImageCacheManager.loadResizedImage(
          TestImageProvider(testImage),
          200.0, // maxWidth
          200.0, // maxHeight
        );

        expect(resizedImage.width, equals(100));
        expect(resizedImage.height, equals(100));

        resizedImage.dispose();
      } finally {
        testImage.dispose();
      }
    });
  });
}

/// Helper class to create test images
class TestImageProvider extends ImageProvider<TestImageProvider> {
  final ui.Image image;

  TestImageProvider(this.image);

  @override
  Future<TestImageProvider> obtainKey(ImageConfiguration configuration) {
    return Future.value(this);
  }

  @override
  ImageStreamCompleter loadImage(
    TestImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image)));
  }
}

/// Create a simple test image
Future<ui.Image> createTestImage(int width, int height, Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  final paint = ui.Paint()..color = color;

  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    paint,
  );

  final picture = recorder.endRecording();
  return picture.toImage(width, height);
}
