import 'models.dart';

abstract class LocationSource {
  Future<bool> isServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<PositionFix> getCurrentPosition();
  Stream<PositionFix> positionStream(PositionSettings settings);
}
