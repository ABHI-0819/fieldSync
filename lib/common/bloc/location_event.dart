import 'package:geolocator/geolocator.dart';

abstract class LocationEvent {}

class StartLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final Position position;

  LocationUpdated(this.position);
}
