import 'package:turf/turf.dart' as turf;

/// Checks whether a given point lies inside a polygon.
bool isPointInsidePolygon({
  required double latitude,
  required double longitude,
  required List<List<turf.Position>> polygonCoordinates,
}) {
  try {
    // Create a Position object directly instead of a Point
    final position = turf.Position(longitude, latitude);

    // Create the polygon
    final polygon = turf.Polygon(coordinates: polygonCoordinates);

    // Check if point is inside polygon
    return turf.booleanPointInPolygon(position, polygon);
  } catch (e) {
    print("Error checking point in polygon: $e");
    return false;
  }
}
/*
/// Checks whether a given point lies inside a polygon.
bool isPointInsidePolygon({
  required double latitude,
  required double longitude,
  required List<List<turf.Position>> polygonCoordinates,
}) {
  try {
    // Create the point
    final  point = turf.Point(coordinates: turf.Position(longitude, latitude));

    // Create the polygon
    final polygon = turf.Polygon(coordinates: polygonCoordinates);

    // Check if point is inside polygon
    return turf.booleanPointInPolygon(point, polygon);
  } catch (e) {
    print("Error checking point in polygon: $e");
    return false;
  }
}

void main() {
  // Example usage
  final polygonCoords = [
    [
      turf.Position(72.832, 19.124), // Mumbai: SW corner
      turf.Position(72.835, 19.124), // SE corner
      turf.Position(72.835, 19.126), // NE corner
      turf.Position(72.832, 19.126), // NW corner
      turf.Position(72.832, 19.124), // Close loop
    ],
  ];

  final latitude = 19.125; // Inside the defined area
  final longitude = 72.834;

  final isInside = isPointInsidePolygon(
    latitude: latitude,
    longitude: longitude,
    polygonCoordinates: polygonCoords,
  );

  print(isInside ? '✅ Point is inside the polygon.' : '❌ Point is outside the polygon.');
}

 */