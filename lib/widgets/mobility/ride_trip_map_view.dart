/// Ride Trip Map View - Track B Ticket #204
/// Purpose: MapView Integration V1 - استهلاك mapStage/mapSnapshot في الـ UI
/// Created by: Track B - Ticket #204
/// Last updated: 2025-12-03
///
/// Widget مخصصة لعرض خريطة الرحلة من حالة السيشن.
/// تقرأ RideTripSessionUiState.mapStage و mapSnapshot.
/// تستخدم MapPort المحقون لدفع الأوامر للخريطة.
///
/// Track B - Ticket #204: Ride Trip MapView Integration V1
/// - Widget واحدة مخصصة لعرض خريطة الرحلة
/// - قراءة mapStage/mapSnapshot من السيشن
/// - استخدام MapPort للأوامر (بدون لمس SDK مباشرة)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Design System imports (Ticket #216 - Design System Integration)
import 'package:design_system_foundation/design_system_foundation.dart';

// Shims only - no direct SDK imports
import 'package:maps_shims/maps_shims.dart';

// App state
import 'package:delivery_ways_clean/state/mobility/ride_trip_session.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_port_providers.dart';
import 'package:delivery_ways_clean/state/mobility/ride_map_projection.dart';

/// Widget مخصصة لعرض خريطة الرحلة من حالة السيشن.
///
/// تقرأ `RideTripSessionUiState.mapStage` و `mapSnapshot` و تستخدم
/// `MapPort` المحقون لدفع الأوامر للخريطة.
///
/// Track B - Ticket #204: استهلاك mapStage/mapSnapshot في الـ UI
class RideTripMapView extends ConsumerWidget {
  const RideTripMapView({
    super.key,
    this.mapSnapshot,
  });

  /// Optional snapshot to display. If null, reads from provider.
  final RideMapSnapshot? mapSnapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rideTripSessionProvider);
    final mapPort = ref.watch(rideMapPortProvider);

    final snapshot = mapSnapshot ?? state.mapSnapshot;
    final stage = state.mapStage;

    // لو ما فيه snapshot: نعرض placeholder بسيط بدون "ديمو" مزيف
    if (snapshot == null) {
      return _buildEmptyMapPlaceholder(stage);
    }

    // لو فيه snapshot: نعرض الخريطة الحقيقية/الموجودة في maps_shims
    return _buildMapFromSnapshot(
      context: context,
      snapshot: snapshot,
      stage: stage,
      port: mapPort,
    );
  }

  /// Placeholder عندما ما يكون فيه snapshot متاح.
  /// لا نستخدم أي منطق عمل وهمي - مجرد SizedBox فارغ.
  Widget _buildEmptyMapPlaceholder(RideMapStage stage) {
    return const SizedBox.expand();
  }

  /// عرض الخريطة من snapshot باستخدام MapPort.
  ///
  /// حالياً: Container مع نص debug يظهر معلومات الـ stage و snapshot.
  /// مستقبلاً: يمكن استبداله بـ MapViewWidget حقيقية تأخذ MapPort.
  Widget _buildMapFromSnapshot({
    required BuildContext context,
    required RideMapSnapshot snapshot,
    required RideMapStage stage,
    required MapPort port,
  }) {
    // TODO: استبدال هذا بـ MapView حقيقي من maps_shims عند توفره
    // مثال مستقبلي:
    // return MapViewWidget(port: port);
    // أو:
    // return MapView(props: MapViewProps(controller: mapControllerFromPort(port)));

    return Container(
      key: const Key('ride_trip_map'),
      color: DwColors().surfaceVariant, // Design System: surfaceVariant instead of hardcoded Colors.blueGrey.shade100
      padding: EdgeInsets.all(DwSpacing().md), // Design System: md spacing instead of hardcoded 16
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 48, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(
              'Map Stage: ${stage.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Markers: ${snapshot.markers.length}, '
              'Polylines: ${snapshot.polylines.length}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (snapshot.markers.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Camera: ${snapshot.cameraTarget.center.latitude.toStringAsFixed(4)}, '
                '${snapshot.cameraTarget.center.longitude.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
