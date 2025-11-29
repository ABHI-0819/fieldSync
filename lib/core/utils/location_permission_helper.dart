import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

Future<bool> handleLocationPermission(BuildContext context) async {
  LocationPermission permission;

  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location services are disabled.')),
    );
    return false;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are denied')),
      );
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Location permissions are permanently denied, enable it in settings.'),
      ),
    );
    return false;
  }

  return true;
}
