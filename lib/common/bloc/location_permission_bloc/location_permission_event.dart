// 1. location_permission_event.dart
abstract class LocationPermissionEvent {}

class CheckLocationPermission extends LocationPermissionEvent {}

class RequestLocationPermission extends LocationPermissionEvent {}

class LocationServiceChanged extends LocationPermissionEvent {
  final bool isEnabled;
  LocationServiceChanged(this.isEnabled);
}

class OpenLocationSettings extends LocationPermissionEvent {}