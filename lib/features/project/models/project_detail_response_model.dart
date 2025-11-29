import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:geojson_vi/geojson_vi.dart';

/// Helper: JSON → Model
ProjectDetailResponse projectDetailResponseFromJson(String str) =>
    ProjectDetailResponse.fromJson(json.decode(str));

/// Helper: Model → JSON string
String projectDetailResponseToJson(ProjectDetailResponse data) =>
    json.encode(data.toJson());

/// Root Response
class ProjectDetailResponse {
  final String status;
  final String message;
  final ProjectDetail data;

  ProjectDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProjectDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: ProjectDetail.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

/// Project Detail
class ProjectDetail {
  final String id;
  final String organizationName;
  final String projectAdminName;
  final String createdByName;
  final String updatedByName;

  final String pid;
  final String name;
  final String code;
  final String description;
  final String locationName;

  final LatLng? point; // ✅ location_coordinates Point
  final GeoJSONPolygon? polygon; // ✅ boundary polygon (GeoJSON)

  final String totalArea;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? expectedCompletionDate;

  final String status;
  final String priority;

  final int expectedTreeCount;
  final String targetCarbonSequestrationKg;

  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectDetail({
    required this.id,
    required this.organizationName,
    required this.projectAdminName,
    required this.createdByName,
    required this.updatedByName,
    required this.pid,
    required this.name,
    required this.code,
    required this.description,
    required this.locationName,
    required this.point,
    required this.polygon,
    required this.totalArea,
    required this.startDate,
    required this.endDate,
    required this.expectedCompletionDate,
    required this.status,
    required this.priority,
    required this.expectedTreeCount,
    required this.targetCarbonSequestrationKg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDetail.fromJson(Map<String, dynamic> json) {
    // Parse point
    LatLng? parsedPoint;
    try {
      if (json['location_coordinates']?['coordinates'] != null) {
        final coords = (json['location_coordinates']['coordinates'] as List);
        // GeoJSON point is [lng, lat]
        parsedPoint = LatLng(coords[1], coords[0]);
      }
    } catch (_) {}

    // Parse polygon (already a Map in your response)
    GeoJSONPolygon? parsedPolygon;
    try {
      if (json['location_boundary'] != null) {
        final featureWrapped = {
          "type": "Feature",
          "geometry": json['location_boundary'],
          "properties": {}
        };
        final geoFeature =
        GeoJSONFeature.fromJSON(jsonEncode(featureWrapped));
        if (geoFeature.geometry is GeoJSONPolygon) {
          parsedPolygon = geoFeature.geometry as GeoJSONPolygon;
        }
      }
    } catch (e) {
      print("Polygon parse error: $e");
    }

    return ProjectDetail(
      id: json['id'] ?? '',
      organizationName: json['organization_name'] ?? '',
      projectAdminName: json['project_admin_name'] ?? '',
      createdByName: json['created_by_name'] ?? '',
      updatedByName: json['updated_by_name'] ?? '',
      pid: json['pid'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      locationName: json['location_name'] ?? '',
      point: parsedPoint,
      polygon: parsedPolygon,
      totalArea: json['total_area'] ?? '',
      startDate: DateTime.tryParse(json['start_date'] ?? ''),
      endDate: DateTime.tryParse(json['end_date'] ?? ''),
      expectedCompletionDate:
      DateTime.tryParse(json['expected_completion_date'] ?? ''),
      status: json['status'] ?? '',
      priority: json['priority'] ?? '',
      expectedTreeCount: json['expected_tree_count'] ?? 0,
      targetCarbonSequestrationKg:
      json['target_carbon_sequestration_kg'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "organization_name": organizationName,
    "project_admin_name": projectAdminName,
    "created_by_name": createdByName,
    "updated_by_name": updatedByName,
    "pid": pid,
    "name": name,
    "code": code,
    "description": description,
    "location_name": locationName,
    "location_coordinates": {
      "type": "Point",
      "coordinates": [point?.longitude, point?.latitude],
    },
    "location_boundary": polygon?.toJSON(),
    "total_area": totalArea,
    "start_date": startDate?.toIso8601String(),
    "end_date": endDate?.toIso8601String(),
    "expected_completion_date":
    expectedCompletionDate?.toIso8601String(),
    "status": status,
    "priority": priority,
    "expected_tree_count": expectedTreeCount,
    "target_carbon_sequestration_kg": targetCarbonSequestrationKg,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  /// ✅ Helper: polygon → LatLng list for flutter_map
  List<LatLng> get polygonLatLngs {
    if (polygon == null) return [];
    final coords = polygon!.coordinates.first;
    return coords.map((p) => LatLng(p[1], p[0])).toList();
  }

  /// ✅ Helper: center point (fallback)
  LatLng get effectiveCenter {
    if (point != null) return point!;
    if (polygon != null) {
      final coords = polygon!.coordinates.first;
      final latSum = coords.fold(0.0, (sum, p) => sum + p[1]);
      final lngSum = coords.fold(0.0, (sum, p) => sum + p[0]);
      return LatLng(latSum / coords.length, lngSum / coords.length);
    }
    return LatLng(0, 0);
  }
}
