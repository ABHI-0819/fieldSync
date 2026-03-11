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
