abstract class LocationEvent {}

class StartLocationTracking extends LocationEvent {}

class LocationUpdated extends LocationEvent {
  final double accuracy;

  LocationUpdated(this.accuracy);
}
