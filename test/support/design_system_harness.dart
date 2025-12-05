// Design System Test Harness
// Created by: Cursor A
// Updated by: FIX-4 - Added provider overrides for DSR screens and MapView stub
// Purpose: Register stub resolvers for design system components in tests
// Last updated: 2025-12-05

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:design_system_shims/src/components.dart';
import 'package:design_system_shims/src/providers.dart';
import 'package:maps_shims/maps_shims.dart' show MapViewParams, mapViewBuilderProvider;
import 'package:foundation_shims/foundation_shims.dart' show trackingEnabledProvider;
import 'package:mobility_shims/mobility.dart' show LocationProvider, LocationPoint, PermissionStatus, BackgroundTracker, TrackingStatus, locationProvider, backgroundTrackerProvider;

bool _designSystemWiredForTests = false;

/// Ensures stub resolvers are registered for design system components.
/// Call this once in setUpAll() before any pumpWidget() calls.
void ensureDesignSystemStubsForTests() {
  if (_designSystemWiredForTests) return;
  _designSystemWiredForTests = true;

  // Register AppCard.standard resolver
  registerAppCardStandardResolver(_StubAppCard.new);

  // Register AppButton.primary resolver
  registerAppButtonPrimaryResolver(_StubAppButton.new);

  // Register AppNotice resolver
  registerAppNoticeResolver(_stubAppNoticeBuilder);
}

/// Returns a list of provider overrides needed for design system stubs.
/// Use this in ProviderScope.overrides for tests that use DSR screens.
List<Override> getDesignSystemTestOverrides() {
  return [
    appSwitchBuilderProvider.overrideWithValue(const _StubAppSwitchBuilder()),
    appNoticePresenterProvider.overrideWithValue(_stubAppNoticePresenter),
    appTextFieldBuilderProvider.overrideWithValue(const _StubAppTextFieldBuilder()),
    mapViewBuilderProvider.overrideWithValue(_stubMapViewBuilder),
    // FIX-4: Enable tracking for tests to avoid TrackingDisabledException
    trackingEnabledProvider.overrideWithValue(true),
    locationProvider.overrideWithValue(const _StubLocationProvider()),
    backgroundTrackerProvider.overrideWithValue(const _StubBackgroundTracker()),
  ];
}

/// Stub MapViewBuilder that returns a simple placeholder widget
Widget _stubMapViewBuilder(MapViewParams params) {
  return Container(
    color: Colors.grey[300],
    child: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Map Stub', style: TextStyle(color: Colors.grey)),
        ],
      ),
    ),
  );
}

/// Stub LocationProvider for tests
class _StubLocationProvider implements LocationProvider {
  const _StubLocationProvider();

  @override
  Stream<LocationPoint> watch() => const Stream<LocationPoint>.empty();

  @override
  Future<LocationPoint> getCurrent() async {
    return const LocationPoint(latitude: 0.0, longitude: 0.0);
  }

  @override
  Future<PermissionStatus> requestPermission() async => PermissionStatus.granted;

  @override
  Future<bool> serviceEnabled() async => true;
}

/// Stub BackgroundTracker for tests
class _StubBackgroundTracker implements BackgroundTracker {
  const _StubBackgroundTracker();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Stream<TrackingStatus> status() => Stream<TrackingStatus>.value(TrackingStatus.stopped);
}

/// Stub AppNotice builder
Widget _stubAppNoticeBuilder(AppNotice notice) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _getNoticeColor(notice.type),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(_getNoticeIcon(notice.type), color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(notice.message, style: const TextStyle(color: Colors.white))),
      ],
    ),
  );
}

Color _getNoticeColor(AppNoticeType type) {
  switch (type) {
    case AppNoticeType.success:
      return Colors.green;
    case AppNoticeType.error:
      return Colors.red;
    case AppNoticeType.warning:
      return Colors.orange;
    case AppNoticeType.info:
      return Colors.blue;
  }
}

IconData _getNoticeIcon(AppNoticeType type) {
  switch (type) {
    case AppNoticeType.success:
      return Icons.check_circle;
    case AppNoticeType.error:
      return Icons.error;
    case AppNoticeType.warning:
      return Icons.warning;
    case AppNoticeType.info:
      return Icons.info;
  }
}

/// Stub AppNotice presenter (no-op for tests)
void _stubAppNoticePresenter(AppNotice notice) {
  // No-op in tests - just consume the notice silently
}

/// Stub implementation of AppSwitch for tests
class _StubAppSwitchBuilder implements AppSwitch {
  const _StubAppSwitchBuilder();

  @override
  Widget build(BuildContext context, AppSwitchProps props) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (props.label != null) Text(props.label!),
        Switch(
          value: props.value,
          onChanged: props.onChanged,
        ),
      ],
    );
  }
}

/// Stub implementation of AppTextField for tests
class _StubAppTextFieldBuilder implements AppTextField {
  const _StubAppTextFieldBuilder();

  @override
  Widget build(BuildContext context, AppTextFieldProps props) {
    return TextField(
      controller: props.controller,
      onChanged: props.onChanged,
      enabled: props.enabled,
      obscureText: props.obscureText,
      keyboardType: props.keyboardType,
      inputFormatters: props.inputFormatters,
      maxLines: props.maxLines,
      decoration: InputDecoration(
        labelText: props.label,
        hintText: props.hint,
        errorText: props.error,
        prefixIcon: props.prefixIcon,
        suffixIcon: props.suffixIcon,
      ),
    );
  }
}

/// Stub implementation of AppCard for tests
class _StubAppCard extends AppCard {
  const _StubAppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Card(
      margin: margin ?? EdgeInsets.zero,
      color: backgroundColor,
      shape: borderRadius != null
          ? RoundedRectangleBorder(borderRadius: borderRadius!)
          : null,
      child: onTap != null
          ? InkWell(onTap: onTap, child: content)
          : content,
    );
  }
}

/// Stub implementation of AppButton for tests
class _StubAppButton extends AppButton {
  const _StubAppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expanded = false,
    this.loading = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expanded;
  final bool loading;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          if (loading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(label),
        ],
      ),
    );
  }
}

