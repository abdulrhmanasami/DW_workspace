// Uplink Providers - Riverpod integration
// Created by: Cursor B-mobility
// Purpose: Riverpod providers for uplink services
// Last updated: 2025-11-14

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_uplink_impl/uplink_config.dart';
import 'uplink_service.dart';

/// Provider for uplink configuration
final uplinkConfigProvider =
    Provider<UplinkConfig>((ref) => const UplinkConfig());

/// Provider for uplink service
final uplinkServiceProvider = Provider<UplinkService>((ref) {
  final config = ref.watch(uplinkConfigProvider);
  final service = UplinkService(config);
  // Initialize on first access
  service.initialize();
  return service;
});

/// Provider for queue size
final uplinkQueueSizeProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(uplinkServiceProvider);
  return service.getQueueSize();
});
