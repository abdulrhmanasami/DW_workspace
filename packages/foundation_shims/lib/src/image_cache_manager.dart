/// Component: ImageCacheManager
/// Created by: Cursor (auto-generated)
/// Purpose: Safe ImageCache management to prevent OOM on low-memory devices
/// Last updated: 2025-11-04

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Safe ImageCache manager to prevent OOM issues
/// BL-102-004: ImageCache OOM mitigation
class ImageCacheManager {
  static const int _maxCacheSize =
      50; // Reasonable limit for low-memory devices
  static const int _maxCacheBytes = 50 * 1024 * 1024; // 50MB limit
  static const Duration _cacheCleanupInterval = Duration(minutes: 5);

  static Timer? _cleanupTimer;
  static bool _isInitialized = false;

  /// Initialize ImageCache with safe limits
  static void initialize() {
    if (_isInitialized) return;

    // Configure ImageCache limits
    PaintingBinding.instance.imageCache.maximumSize = _maxCacheSize;
    PaintingBinding.instance.imageCache.maximumSizeBytes = _maxCacheBytes;

    // Set up periodic cleanup
    _cleanupTimer = Timer.periodic(
      _cacheCleanupInterval,
      (_) => _cleanupCache(),
    );

    // Listen for memory pressure
    // Note: onMemoryPressure is not available in current Flutter version
    // Memory pressure handling will be done via periodic cleanup

    _isInitialized = true;

    if (kDebugMode) {
      debugPrint(
        'ImageCacheManager: Initialized with maxSize=$_maxCacheSize, maxBytes=${_maxCacheBytes ~/ (1024 * 1024)}MB',
      );
    }
  }

  /// Force cleanup of image cache
  static void _cleanupCache() {
    if (!_isInitialized) return;

    final cache = PaintingBinding.instance.imageCache;

    // Clear cache if it exceeds safe limits
    if (cache.currentSize > _maxCacheSize * 0.8 ||
        cache.currentSizeBytes > _maxCacheBytes * 0.8) {
      cache.clear();
      cache.clearLiveImages();

      if (kDebugMode) {
        debugPrint('ImageCacheManager: Cache cleared due to size limits');
      }
    }
  }

  /// Safely load and resize image to prevent large image OOM
  static Future<ui.Image> loadResizedImage(
    ImageProvider provider,
    double maxWidth,
    double maxHeight,
  ) async {
    try {
      // Load the image
      final ImageStream stream = provider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();

      late ImageStreamListener listener;
      listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      });

      stream.addListener(listener);

      final ui.Image originalImage = await completer.future;

      // Check if resizing is needed
      if (originalImage.width <= maxWidth &&
          originalImage.height <= maxHeight) {
        return originalImage;
      }

      // Calculate new dimensions maintaining aspect ratio
      final double aspectRatio = originalImage.width / originalImage.height;
      double newWidth = maxWidth;
      double newHeight = maxWidth / aspectRatio;

      if (newHeight > maxHeight) {
        newHeight = maxHeight;
        newWidth = maxHeight * aspectRatio;
      }

      // Resize the image
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      canvas.scale(
        newWidth / originalImage.width,
        newHeight / originalImage.height,
      );
      canvas.drawImage(originalImage, ui.Offset.zero, ui.Paint());

      final ui.Picture picture = recorder.endRecording();
      final ui.Image resizedImage = await picture.toImage(
        newWidth.toInt(),
        newHeight.toInt(),
      );

      // Dispose original image to free memory
      originalImage.dispose();

      return resizedImage;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ImageCacheManager: Failed to load/resize image: $e');
      }
      rethrow;
    }
  }

  /// Dispose resources
  static void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    _isInitialized = false;
  }

  /// Get current cache stats for debugging
  static Map<String, dynamic> getCacheStats() {
    final cache = PaintingBinding.instance.imageCache;
    return {
      'currentSize': cache.currentSize,
      'maximumSize': cache.maximumSize,
      'currentSizeBytes': cache.currentSizeBytes,
      'maximumSizeBytes': cache.maximumSizeBytes,
      'isInitialized': _isInitialized,
    };
  }
}
