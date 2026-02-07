// 3. location_permission_bloc.dart (UPDATED)
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart' as geo;

import 'location_permission_event.dart';
import 'location_permission_state.dart';

class LocationPermissionBloc
    extends Bloc<LocationPermissionEvent, LocationPermissionState> {
  StreamSubscription<geo.ServiceStatus>? _serviceStatusSubscription;

  LocationPermissionBloc() : super(LocationPermissionState.initial()) {
    on<CheckLocationPermission>(_onCheckLocationPermission);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<LocationServiceChanged>(_onLocationServiceChanged);
    on<OpenLocationSettings>(_onOpenLocationSettings);

    // Start monitoring location service status
    _monitorLocationService();
    
    // Initial check
    add(CheckLocationPermission());
  }

  void _monitorLocationService() {
    _serviceStatusSubscription = geo.Geolocator.getServiceStatusStream().listen(
      (geo.ServiceStatus status) {
        add(LocationServiceChanged(status == geo.ServiceStatus.enabled));
      },
    );
  }

  Future<void> _onCheckLocationPermission(
    CheckLocationPermission event,
    Emitter<LocationPermissionState> emit,
  ) async {
    emit(state.copyWith(status: LocationPermissionStatus.checking));

    try {
      // Check if location service is enabled
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        emit(state.copyWith(
          status: LocationPermissionStatus.serviceDisabled,
          isLocationServiceEnabled: false,
          message: 'Location service is disabled',
        ));
        return;
      }

      // Check permission status
      final permission = await Permission.location.status;

      if (permission.isGranted) {
        emit(state.copyWith(
          status: LocationPermissionStatus.granted,
          isLocationServiceEnabled: true,
          message: 'Location permission granted',
        ));
      } else if (permission.isDenied) {
        emit(state.copyWith(
          status: LocationPermissionStatus.denied,
          isLocationServiceEnabled: serviceEnabled,
          message: 'Location permission is required for geo-tagging',
        ));
      } else if (permission.isPermanentlyDenied) {
        emit(state.copyWith(
          status: LocationPermissionStatus.permanentlyDenied,
          isLocationServiceEnabled: serviceEnabled,
          message: 'Please enable location from settings',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationPermissionStatus.denied,
        message: 'Error checking location permission: $e',
      ));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<LocationPermissionState> emit,
  ) async {
    try {
      // First check if service is enabled
      final serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        emit(state.copyWith(
          status: LocationPermissionStatus.serviceDisabled,
          isLocationServiceEnabled: false,
          message: 'Please enable location service',
        ));
        return;
      }

      // Request permission
      final status = await Permission.location.request();

      if (status.isGranted) {
        emit(state.copyWith(
          status: LocationPermissionStatus.granted,
          isLocationServiceEnabled: true,
          message: 'Location permission granted',
        ));
      } else if (status.isDenied) {
        emit(state.copyWith(
          status: LocationPermissionStatus.denied,
          isLocationServiceEnabled: serviceEnabled,
          message: 'Location permission denied',
        ));
      } else if (status.isPermanentlyDenied) {
        emit(state.copyWith(
          status: LocationPermissionStatus.permanentlyDenied,
          isLocationServiceEnabled: serviceEnabled,
          message: 'Please enable location from app settings',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationPermissionStatus.denied,
        message: 'Error requesting permission: $e',
      ));
    }
  }

  Future<void> _onLocationServiceChanged(
    LocationServiceChanged event,
    Emitter<LocationPermissionState> emit,
  ) async {
    if (!event.isEnabled) {
      emit(state.copyWith(
        status: LocationPermissionStatus.serviceDisabled,
        isLocationServiceEnabled: false,
        message: 'Location service has been disabled',
      ));
    } else {
      // Re-check permission when service is enabled
      add(CheckLocationPermission());
    }
  }

  Future<void> _onOpenLocationSettings(
    OpenLocationSettings event,
    Emitter<LocationPermissionState> emit,
  ) async {
    if (state.status == LocationPermissionStatus.serviceDisabled) {
      await geo.Geolocator.openLocationSettings();
    } else {
      await openAppSettings();
    }
  }

  @override
  Future<void> close() {
    _serviceStatusSubscription?.cancel();
    return super.close();
  }
}