/// Component: Mobility Background Screen
/// Created by: Cursor (auto-generated)
/// Purpose: Background tracking, geofence, and trip smoke tests (Phase-3)
/// Last updated: 2025-11-11

import 'package:design_system_foundation/design_system_foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobility_shims/mobility.dart' as mob;

import '../state/infra/mobility_providers.dart';

class MobilityBgScreen extends ConsumerStatefulWidget {
  const MobilityBgScreen({super.key});

  @override
  ConsumerState<MobilityBgScreen> createState() => _MobilityBgScreenState();
}

class _MobilityBgScreenState extends ConsumerState<MobilityBgScreen> {
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('[${DateTime.now().toIso8601String()}] $message');
      if (_logs.length > 50) {
        _logs.removeAt(0); // Keep only last 50 logs
      }
    });
  }

  Future<void> _runBackgroundSmokeTest() async {
    _addLog('Starting Background Tracking Smoke Test...');

    final backgroundController = ref.read(backgroundTrackingControllerProvider);

    try {
      // Start background tracking
      await backgroundController.startForeground();
      _addLog('Background tracking started');

      // Listen to tracking state for 10 seconds
      final subscription = backgroundController.state.listen((state) {
        _addLog('Tracking state: ${state.status}');
        if (state.lastPoint != null) {
          _addLog(
            'Location: ${state.lastPoint!.latitude}, ${state.lastPoint!.longitude}',
          );
        }
      });

      await Future.delayed(const Duration(seconds: 10));

      // Stop tracking
      await backgroundController.stop();
      await subscription.cancel();

      _addLog('Background tracking smoke test completed successfully');
    } catch (e) {
      _addLog('Background tracking smoke test failed: $e');
    }
  }

  Future<void> _runGeofenceSmokeTest() async {
    _addLog('Starting Geofence Smoke Test...');

    final geofenceManager = ref.read(geofenceManagerProvider);

    try {
      const center = mob.LocationPoint(
        latitude: 50.0,
        longitude: 6.9,
        accuracyMeters: 25,
      );
      const radiusMeters = 100.0;

      final region = mob.GeofenceRegion(
        id: 'smoke_test_geofence',
        latitude: center.latitude,
        longitude: center.longitude,
        radiusMeters: radiusMeters,
      );

      await geofenceManager.setGeofences([region]);
      _addLog(
        'Geofence set at test location (${radiusMeters.toStringAsFixed(0)}m radius)',
      );

      final enterSub = geofenceManager.onEnter.listen((event) {
        final ts = event.timestamp ?? DateTime.now();
        _addLog('Enter ${event.id} at $ts');
      });
      final exitSub = geofenceManager.onExit.listen((event) {
        final ts = event.timestamp ?? DateTime.now();
        _addLog('Exit ${event.id} at $ts');
      });

      await Future.delayed(const Duration(seconds: 15));

      await enterSub.cancel();
      await exitSub.cancel();
      _addLog('Geofence smoke test completed (events require movement)');
    } catch (e) {
      _addLog('Geofence smoke test failed: $e');
    }
  }

  Future<void> _runTripSmokeTest() async {
    _addLog('Starting Trip Recording Smoke Test...');

    final tripRecorder = ref.read(tripRecorderProvider);

    try {
      // Start trip recording
      await tripRecorder.beginTrip('smoke_test_trip');
      _addLog('Trip recording started');

      // Listen to trip points for 10 seconds
      final subscription = tripRecorder.points.listen((
        mob.LocationPoint point,
      ) {
        _addLog('Trip point recorded: ${point.latitude}, ${point.longitude}');
      });

      await Future.delayed(const Duration(seconds: 10));

      // End trip
      await tripRecorder.endTrip();
      await subscription.cancel();

      _addLog('Trip recording smoke test completed successfully');
    } catch (e) {
      _addLog('Trip recording smoke test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobility Background Tests (Phase-3)')),
      body: Column(
        children: [
          // Test buttons
          Padding(
            padding: EdgeInsets.all(DwSpacing().md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _runBackgroundSmokeTest,
                  child: const Text('Test Background Tracking'),
                ),
                SizedBox(height: DwSpacing().sm),
                ElevatedButton(
                  onPressed: _runGeofenceSmokeTest,
                  child: const Text('Test Geofence'),
                ),
                SizedBox(height: DwSpacing().sm),
                ElevatedButton(
                  onPressed: _runTripSmokeTest,
                  child: const Text('Test Trip Recording'),
                ),
                SizedBox(height: DwSpacing().md),
                Text(
                  'Test Logs:',
                  style: DwTypography().headline6.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Logs display
          Expanded(
            child: Container(
              margin: EdgeInsets.all(DwSpacing().md),
              padding: EdgeInsets.all(DwSpacing().sm),
              decoration: BoxDecoration(
                border: Border.all(color: DwColors().grey400),
                borderRadius: BorderRadius.circular(DwSpacing().borderRadiusMd),
              ),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: DwSpacing().xxs),
                    child: Text(
                      _logs[_logs.length - 1 - index], // Show newest first
                      style: DwTypography().caption,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
