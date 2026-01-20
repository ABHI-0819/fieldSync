
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription<Position>? _positionSub;

  LocationBloc() : super(const LocationState()) {
    on<StartLocationTracking>(_onStartTracking);
    on<LocationUpdated>(_onLocationUpdated);
  }

  Future<void> _onStartTracking(
    StartLocationTracking event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(isTracking: true));

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen((position) {
      add(LocationUpdated(position.accuracy));
    });
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) {
    emit(state.copyWith(accuracy: event.accuracy));
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    return super.close();
  }
}
