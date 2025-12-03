// Tracking Screen - Live Location with Maps Integration
// Created by: Cursor B-mobility
// Purpose: Complete tracking UI with map visualization and session control
// Last updated: 2025-11-14

import 'dart:async';
import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_shims/foundation_shims.dart' as fnd;
import 'package:maps_shims/maps.dart' as maps;
import 'package:mobility_shims/mobility.dart' as mob;
import 'package:design_system_shims/design_system_shims.dart';

import '../../state/mobility/tracking_controller.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  maps.MapController? _mapController;
  final List<mob.LocationPoint> _polylinePoints = [];
  static const int _maxPolylinePoints = 200; // Configurable via RemoteConfig
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    // Initialize tracking on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackingControllerProvider.notifier).init();
    });
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapReady(maps.MapController controller) {
    _mapController = controller;
    _updateMapMarker();
  }

  void _updateMapMarker() {
    // Throttle UI updates to avoid excessive map redraws
    _throttleTimer?.cancel();
    _throttleTimer = Timer(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      final sessionState = ref.read(trackingControllerProvider);
      final mob.LocationPoint? lastPoint = sessionState.lastPoint;
      if (_mapController != null && lastPoint != null) {
        // Update polyline with new point
        _updatePolyline(lastPoint);

        // Update current location marker
        final marker = maps.MapMarker(
          id: maps.MapMarkerId('current_location'),
          position: maps.GeoPoint(lastPoint.latitude, lastPoint.longitude),
          label: 'موقعك الحالي',
        );
        _mapController!.setMarkers([marker]);
      }
    });
  }

  void _updatePolyline(mob.LocationPoint point) {
    // Add point to polyline window
    _polylinePoints.add(point);

    // Maintain sliding window
    if (_polylinePoints.length > _maxPolylinePoints) {
      _polylinePoints.removeAt(0);
    }

    // Update map polyline
    if (_mapController != null && _polylinePoints.length >= 2) {
      final polylinePoints = _polylinePoints
          .map(
            (p) => maps.MapPoint(latitude: p.latitude, longitude: p.longitude),
          )
          .toList();

      // Note: This assumes MapController has addPolyline/updatePolyline methods
      // In actual implementation, this would depend on the maps_shims interface
      // For now, we'll use a placeholder
      _updateMapPolyline(polylinePoints);
    }
  }

  void _updateMapPolyline(List<maps.MapPoint> points) {
    // This is a placeholder - actual implementation would depend on maps_shims API
    // The maps_shims package would need to be updated to support polylines
    // For now, we'll just update markers to show the path
    if (_mapController != null) {
      final markers = points
          .map(
            (point) => maps.MapMarker(
              id: maps.MapMarkerId('polyline_${points.indexOf(point)}'),
              position: maps.GeoPoint(point.latitude, point.longitude),
              label: 'مسار الرحلة',
            ),
          )
          .toList();

      // Add current location marker on top
      final sessionState = ref.read(trackingControllerProvider);
      final mob.LocationPoint? lastPoint = sessionState.lastPoint;
      if (lastPoint != null) {
        markers.add(
          maps.MapMarker(
            id: maps.MapMarkerId('current_location'),
            position: maps.GeoPoint(lastPoint.latitude, lastPoint.longitude),
            label: 'موقعك الحالي',
          ),
        );
      }

      _mapController!.setMarkers(markers);
    }
  }

  void _clearPolyline() {
    _polylinePoints.clear();
    _updateMapMarker(); // Reset to just current location
  }

  Future<void> _startTracking() async {
    try {
      await ref.read(trackingControllerProvider.notifier).start();
    } catch (e) {
      // Error handling is done in controller via notices
      debugPrint('Failed to start tracking: $e');
    }
  }

  Future<void> _stopTracking() async {
    try {
      await ref.read(trackingControllerProvider.notifier).stop();
      // Clear polyline when stopping
      _clearPolyline();
    } catch (e) {
      debugPrint('Failed to stop tracking: $e');
    }
  }

  Widget _buildStatusCard(TrackingSessionState state) {
    // Use Theme.of(context) for unified theme access (Track A - Ticket #1)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    Color statusColor;
    String statusText;
    IconData statusIcon;
    final mob.LocationPoint? lastPoint = state.lastPoint;

    // Map status to theme-aware colors
    switch (state.status) {
      case mob.TrackingStatus.stopped:
        statusColor = colorScheme.outline; // Grey from theme
        statusText = 'متوقف';
        statusIcon = Icons.stop;
        break;
      case mob.TrackingStatus.starting:
        statusColor = colorScheme.tertiary; // Orange/accent from theme
        statusText = 'يبدأ...';
        statusIcon = Icons.hourglass_empty;
        break;
      case mob.TrackingStatus.running:
        statusColor = colorScheme.primary; // Green primary from theme
        statusText = 'يعمل';
        statusIcon = Icons.play_arrow;
        break;
      case mob.TrackingStatus.paused:
        statusColor = colorScheme.secondary; // Secondary from theme
        statusText = 'متوقف مؤقتاً';
        statusIcon = Icons.pause;
        break;
      case mob.TrackingStatus.error:
        statusColor = colorScheme.error; // Error from theme
        statusText = 'خطأ';
        statusIcon = Icons.error;
        break;
    }

    return AppCard.standard(
      child: Padding(
        padding: EdgeInsets.all(DwSpacing().md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor),
                SizedBox(width: DwSpacing().sm),
                Text(
                  'حالة التتبع: $statusText',
                  style: textTheme.titleSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (state.permission != null) ...[
              SizedBox(height: DwSpacing().sm),
              Text(
                'الصلاحيات: ${_getPermissionText(state.permission!)}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
            if (lastPoint != null) ...[
              SizedBox(height: DwSpacing().sm),
              Text(
                'آخر تحديث: ${_formatTimestamp(state.lastUpdate)}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'الإحداثيات: ${lastPoint.latitude.toStringAsFixed(6)}, ${lastPoint.longitude.toStringAsFixed(6)}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
            if (state.errorMessage != null) ...[
              SizedBox(height: DwSpacing().sm),
              Text(
                'خطأ: ${state.errorMessage}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getPermissionText(mob.PermissionStatus status) {
    switch (status) {
      case mob.PermissionStatus.granted:
        return 'ممنوح';
      case mob.PermissionStatus.denied:
        return 'مرفوض';
      case mob.PermissionStatus.permanentlyDenied:
        return 'مرفوض نهائياً';
      case mob.PermissionStatus.restricted:
        return 'مقيد';
      case mob.PermissionStatus.notDetermined:
        return 'غير محدد';
    }
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'غير محدد';
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'منذ ${difference.inSeconds} ثانية';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return timestamp.toString().substring(11, 19); // HH:MM:SS
    }
  }

  Widget _buildIosWarningBanner() {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return const SizedBox.shrink();
    }

    // Use Theme.of(context) for unified theme access (Track A - Ticket #1)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      color: colorScheme.surfaceContainerHighest,
      padding: EdgeInsets.all(DwSpacing().sm),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.tertiary),
          SizedBox(width: DwSpacing().sm),
          Expanded(
            child: Text(
              'على iOS: التتبع محدود بالوضع المقدم. التتبع الخلفي يتطلب تكوين إضافي في المشروع.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.tertiary),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(TrackingSessionState state) {
    // Use Theme.of(context) for unified theme access (Track A - Ticket #1)
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isTrackingEnabled = ref.watch(mob.mobilityConfigProvider);
    final isConsentGranted = ref.watch(mob.consentBackgroundLocationProvider);

    if (!isTrackingEnabled) {
      return AppCard.standard(
        child: Padding(
          padding: EdgeInsets.all(DwSpacing().md),
          child: Column(
            children: [
              Icon(Icons.warning, color: colorScheme.tertiary, size: 48),
              SizedBox(height: DwSpacing().md),
              Text(
                'التتبع معطل في إعدادات النظام',
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DwSpacing().sm),
              Text(
                'يرجى تفعيل التتبع من إعدادات التطبيق',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!isConsentGranted) {
      return AppCard.standard(
        child: Padding(
          padding: EdgeInsets.all(DwSpacing().md),
          child: Column(
            children: [
              Icon(Icons.privacy_tip, color: colorScheme.primary, size: 48),
              SizedBox(height: DwSpacing().md),
              Text(
                'مطلوب موافقة تتبع الموقع',
                textAlign: TextAlign.center,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: DwSpacing().md),
              AppButton.primary(
                label: 'الانتقال لإعدادات الخصوصية',
                onPressed: () {
                  ref
                      .read(fnd.navigatorKeyProvider)
                      .currentState
                      ?.pushNamed('/settings/privacy-consent');
                },
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: AppButton.primary(
            label: 'بدء التتبع',
            expanded: true,
            onPressed: state.status == mob.TrackingStatus.stopped
                ? _startTracking
                : null,
          ),
        ),
        SizedBox(width: DwSpacing().md),
        Expanded(
          child: AppButton.primary(
            label: 'إيقاف',
            expanded: true,
            onPressed: state.status == mob.TrackingStatus.running
                ? _stopTracking
                : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(trackingControllerProvider);
    final buildMap = ref.watch(maps.mapViewBuilderProvider);
    final mob.LocationPoint? focusPoint = sessionState.lastPoint;

    // Update map marker when location changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMapMarker();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('تتبع الموقع')),
      body: Column(
        children: [
          // iOS warning banner
          _buildIosWarningBanner(),

          // Status card
          Padding(
            padding: EdgeInsets.all(DwSpacing().md),
            child: _buildStatusCard(sessionState),
          ),

          // Control buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildControlButtons(sessionState),
          ),

          // Map view
          Expanded(
            child: buildMap(
              maps.MapViewParams(
                initialCameraPosition: focusPoint != null
                    ? maps.MapCamera(
                        target: maps.MapPoint(
                          latitude: focusPoint.latitude,
                          longitude: focusPoint.longitude,
                        ),
                        zoom: 16.0,
                      )
                    : maps.MapCamera(
                        target: maps.MapPoint(
                          latitude: 24.7136,
                          longitude: 46.6753,
                        ), // Riyadh default
                        zoom: 12.0,
                      ),
                onMapReady: _onMapReady,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
