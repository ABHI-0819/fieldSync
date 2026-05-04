import 'package:geolocator/geolocator.dart';

class LocationState {
  final double? accuracy;
  final bool isTracking;
  final Position? position;

  const LocationState({
    this.accuracy,
    this.isTracking = false,
    this.position,
  });

  LocationState copyWith({
    double? accuracy,
    bool? isTracking,
    Position? position,
  }) {
    return LocationState(
      accuracy: accuracy ?? this.accuracy,
      isTracking: isTracking ?? this.isTracking,
      position: position ?? this.position,
    );
  }
}
