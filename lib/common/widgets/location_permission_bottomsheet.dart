// 4. location_permission_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/location_permission_bloc/location_permission_bloc.dart';
import '../bloc/location_permission_bloc/location_permission_event.dart';
import '../bloc/location_permission_bloc/location_permission_state.dart';

class LocationPermissionListener extends StatelessWidget {
  final Widget child;

  const LocationPermissionListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationPermissionBloc, LocationPermissionState>(
      listenWhen: (previous, current) {
        // Show bottom sheet when status changes to denied/disabled
        return current.shouldShowBottomSheet &&
            previous.status != current.status;
      },
      listener: (context, state) {
        _showLocationPermissionSheet(context, state);
      },
      child: child,
    );
  }

  void _showLocationPermissionSheet(
    BuildContext context,
    LocationPermissionState state,
  ) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: _LocationPermissionContent(state: state),
      ),
    );
  }
}

class _LocationPermissionContent extends StatelessWidget {
  final LocationPermissionState state;

  const _LocationPermissionContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isServiceDisabled =
        state.status == LocationPermissionStatus.serviceDisabled;
    final isPermanentlyDenied =
        state.status == LocationPermissionStatus.permanentlyDenied;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isServiceDisabled ? Colors.orange[50] : Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isServiceDisabled ? Icons.location_off : Icons.location_on,
              size: 32,
              color: isServiceDisabled ? Colors.orange[700] : Colors.red[700],
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            isServiceDisabled
                ? 'Location Service Disabled'
                : 'Location Permission Required',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            isServiceDisabled
                ? 'Please enable location service on your device to continue with tree geo-tagging and surveying.'
                : isPermanentlyDenied
                    ? 'Location permission is permanently denied. Please enable it from app settings to use tree geo-tagging features.'
                    : 'We need access to your device location for accurate tree geo-tagging and surveying. This helps us record the precise GPS coordinates of each tree.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // Primary Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (isServiceDisabled || isPermanentlyDenied) {
                  context
                      .read<LocationPermissionBloc>()
                      .add(OpenLocationSettings());
                } else {
                  context
                      .read<LocationPermissionBloc>()
                      .add(RequestLocationPermission());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isServiceDisabled || isPermanentlyDenied
                    ? 'Open Settings'
                    : 'Allow Location Access',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
