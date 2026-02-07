// 2. location_permission_state.dart
enum LocationPermissionStatus {
  initial,
  checking,
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class LocationPermissionState {
  final LocationPermissionStatus status;
  final String? message;
  final bool isLocationServiceEnabled;

  const LocationPermissionState({
    required this.status,
    this.message,
    required this.isLocationServiceEnabled,
  });

  factory LocationPermissionState.initial() {
    return const LocationPermissionState(
      status: LocationPermissionStatus.initial,
      isLocationServiceEnabled: false,
    );
  }

  LocationPermissionState copyWith({
    LocationPermissionStatus? status,
    String? message,
    bool? isLocationServiceEnabled,
  }) {
    return LocationPermissionState(
      status: status ?? this.status,
      message: message ?? this.message,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }

  bool get shouldShowBottomSheet =>
      status == LocationPermissionStatus.denied ||
      status == LocationPermissionStatus.permanentlyDenied ||
      status == LocationPermissionStatus.serviceDisabled;

  bool get isLocationReady =>
      status == LocationPermissionStatus.granted &&
      isLocationServiceEnabled;
}