import 'dart:convert';

import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:geojson_vi/geojson_vi.dart';

// ------------------- Root Response -------------------
TreeSurveyResponseList treeSurveyResponseListFromJson(String str) =>
    TreeSurveyResponseList.fromJson(json.decode(str));

String treeSurveyResponseListToJson(TreeSurveyResponseList data) =>
    json.encode(data.toJson());

class TreeSurveyResponseList {
  final String status;
  final String message;
  final List<TreeSurveyData> data;

  TreeSurveyResponseList({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TreeSurveyResponseList.fromJson(Map<String, dynamic> json) =>
      TreeSurveyResponseList(
        status: json["status"] as String? ?? '',
        message: json["message"] as String? ?? '',
        data: (json["data"] as List<dynamic>?)
            ?.map((x) => TreeSurveyData.fromJson(x))
            .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

// ------------------- Single Tree Survey -------------------
class TreeSurveyData {
  final String id;
  final String tid;
  final String project;
  final String projectName;
  final String projectCode;
  final String species;
  final String speciesName;
  final String speciesNameMarathi;
  final String speciesScientificName;
  final String ownership;
  final double? carbonSequestration;
  final Location? location;
  final Thumbnail? thumbnail;
  final String height;
  final String girth;
  final double diameterCm;
  final double? canopyDiameter;
  final double? estimatedAge;
  final String treeAgeGroup;
  final String healthStatus;
  final String siteQuality;
  final String damageSeverity;
  final String createdByName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TreeSurveyData({
    required this.id,
    required this.tid,
    required this.project,
    required this.projectName,
    required this.projectCode,
    required this.species,
    required this.speciesName,
    required this.speciesNameMarathi,
    required this.speciesScientificName,
    required this.ownership,
    this.carbonSequestration,
    this.location,
    this.thumbnail,
    required this.height,
    required this.girth,
    required this.diameterCm,
    this.canopyDiameter,
    this.estimatedAge,
    required this.treeAgeGroup,
    required this.healthStatus,
    required this.siteQuality,
    required this.damageSeverity,
    required this.createdByName,
    this.createdAt,
    this.updatedAt,
  });

  factory TreeSurveyData.fromJson(Map<String, dynamic> json) {
    double? safeDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    DateTime? safeDate(dynamic val) {
      if (val is String) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return null;
    }

    return TreeSurveyData(
      id: json["id"] ?? '',
      tid: json["tid"] ?? '',
      project: json["project"] ?? '',
      projectName: json["project_name"] ?? '',
      projectCode: json["project_code"] ?? '',
      species: json["species"] ?? '',
      speciesName: json["species_name"] ?? '',
      speciesNameMarathi: json["species_name_marathi"] ?? '',
      speciesScientificName: json["species_scientific_name"] ?? '',
      ownership: json["ownership"] ?? '',
      carbonSequestration: safeDouble(json["carbon_sequestration"]),
      location: json["location"] != null ? Location.fromJson(json["location"]) : null,
      thumbnail: json["thumbnail"] != null ? Thumbnail.fromJson(json["thumbnail"]) : null,
      height: json["height"] ?? '0.0',
      girth: json["girth"] ?? '0.0',
      diameterCm: safeDouble(json["diameter_cm"]) ?? 0.0,
      canopyDiameter: safeDouble(json["canopy_diameter"]),
      estimatedAge: safeDouble(json["estimated_age"]),
      treeAgeGroup: json["tree_age_group"] ?? 'Unknown',
      healthStatus: json["health_status"] ?? 'Unknown',
      siteQuality: json["site_quality"] ?? 'Unknown',
      damageSeverity: json["damage_severity"] ?? 'Unknown',
      createdByName: json["created_by_name"] ?? 'Unknown',
      createdAt: safeDate(json["created_at"]),
      updatedAt: safeDate(json["updated_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "tid": tid,
    "project": project,
    "project_name": projectName,
    "project_code": projectCode,
    "species": species,
    "species_name": speciesName,
    "species_name_marathi": speciesNameMarathi,
    "species_scientific_name": speciesScientificName,
    "ownership": ownership,
    "carbon_sequestration": carbonSequestration,
    "location": location?.toJson(),
    "thumbnail": thumbnail?.toJson(),
    "height": height,
    "girth": girth,
    "diameter_cm": diameterCm,
    "canopy_diameter": canopyDiameter,
    "estimated_age": estimatedAge,
    "tree_age_group": treeAgeGroup,
    "health_status": healthStatus,
    "site_quality": siteQuality,
    "damage_severity": damageSeverity,
    "created_by_name": createdByName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

// ------------------- Location with LatLng + GeoJSON -------------------
class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    type: json["type"] ?? 'Point',
    coordinates: (json["coordinates"] as List<dynamic>?)
        ?.map((x) => (x as num).toDouble())
        .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates,
  };

  /// Direct LatLng getter for mapping
  LatLng? get latLng =>
      coordinates.length >= 2 ? LatLng(coordinates[1], coordinates[0]) : null;

  /// GeoJSON conversion helper
  GeoJSONPoint get toGeoJson => GeoJSONPoint(coordinates);
}

// ------------------- Thumbnail -------------------
class Thumbnail {
  final String url;

  Thumbnail({required this.url});

  factory Thumbnail.fromJson(Map<String, dynamic> json) =>
      Thumbnail(url: json["url"] ?? '');

  Map<String, dynamic> toJson() => {"url": url};
}
