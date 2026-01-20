class LocationState {
  final double? accuracy;
  final bool isTracking;

  const LocationState({
    this.accuracy,
    this.isTracking = false,
  });

  LocationState copyWith({
    double? accuracy,
    bool? isTracking,
  }) {
    return LocationState(
      accuracy: accuracy ?? this.accuracy,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}
