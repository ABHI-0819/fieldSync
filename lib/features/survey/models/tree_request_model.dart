/*
class TreeSurveyRequest {
  final String project;
  final String? species;
  final Location? location;
  final String? ownership;
  final String? height;
  final String? girth;
  final String? canopyDiameter;
  final int? estimatedAge;
  final String? healthStatus;
  final String? soilType;
  final String? siteQuality;
  final String? threats;
  final String? damageSeverity;
  final List<File>? images; // 👈 files for form-data
  final String? remark;
  final String? fieldOfficer;

  TreeSurveyRequest({
    required this.project,
    required this.species,
    required this.location,
    this.ownership,
    this.height,
    this.girth,
    this.canopyDiameter,
    this.estimatedAge,
    this.healthStatus,
    this.soilType,
    this.siteQuality,
    this.threats,
    this.damageSeverity,
    this.images,
    this.remark,
    this.fieldOfficer,
  });

  /// Convert only text fields (exclude files)
  Map<String, String> toJsonStringFields() {
    final Map<String, String> data = {};

    if (project != null) data['project'] = project!;
    if (species != null) data['species'] = species!;
    if (location != null) data['location'] = location!.toJsonString();
    if (ownership != null) data['ownership'] = ownership!;
    if (height != null) data['height'] = height!;
    if (girth != null) data['girth'] = girth!;
    if (canopyDiameter != null) data['canopy_diameter'] = canopyDiameter!;
    if (estimatedAge != null) data['estimated_age'] = estimatedAge.toString();
    if (healthStatus != null) data['health_status'] = healthStatus!;
    if (soilType != null) data['soil_type'] = soilType!;
    if (siteQuality != null) data['site_quality'] = siteQuality!;
    if (threats != null) data['threats'] = threats!;
    if (damageSeverity != null) data['damage_severity'] = damageSeverity!;
    if (remark != null) data['remark'] = remark!;
    if (fieldOfficer != null) data['field_officer'] = fieldOfficer!;

    return data;
  }
}

class Location {
  final String type; // always "Point"
  final List<double> coordinates; // [lat, long]

  Location({required this.type, required this.coordinates});

  /// Stored as string JSON because form-data only accepts string values
  String toJsonString() {
    return '{"type":"$type","coordinates":[${coordinates[0]},${coordinates[1]}]}';
  }
}

 */
import 'dart:convert';
import 'dart:io';

class TreeSurveyRequest {
  // ✅ Required
  final String project;               // uuid
  final String species;               // uuid
  final Map<String, dynamic> location; // GeoJSON point { "type": "Point", "coordinates": [lat, lng] }
  final String height;                // decimal
  final String girth;                 // decimal
  final String healthStatus;          // excellent, good, fair, poor, dead, dying

  // ⚡ Optional
  final String? ownership;
  final String? canopyDiameter;
  final int? estimatedAge;
  final String? soilType;
  final String? siteQuality;          // excellent, good, fair, poor
  final String? threats;
  final String? damageSeverity;       // none, minor, moderate, severe, critical
  final List<File> images;
  final String? remark;
  final String? fieldOfficer;

  TreeSurveyRequest({
    required this.project,
    required this.species,
    required this.location,
    required this.height,
    required this.girth,
    required this.healthStatus,
    this.ownership,
    this.canopyDiameter,
    this.estimatedAge,
    this.soilType,
    this.siteQuality,
    this.threats,
    this.damageSeverity,
    this.remark,
    this.fieldOfficer,
    this.images = const [],
  });

  /// ✅ Convert → JSON Map (for APIs that expect raw JSON)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      "project": project,
      "species": species,
      "location": jsonEncode(location),
      "height": height,
      "girth": girth,
      "health_status": healthStatus,
    };

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        if (value is String && value.trim().isEmpty) return;
        if (value is List && value.isEmpty) return;
        jsonMap[key] = value;
      }
    }

    addIfNotNull("ownership", ownership);
    addIfNotNull("canopy_diameter", canopyDiameter);
    addIfNotNull("estimated_age", estimatedAge?.toString());
    addIfNotNull("soil_type", soilType);
    addIfNotNull("site_quality", siteQuality);
    addIfNotNull("threats", threats);
    addIfNotNull("damage_severity", damageSeverity);
    addIfNotNull("remark", remark);
    addIfNotNull("field_officer", fieldOfficer);

    return jsonMap;
  }

  /// ✅ Encode whole request as JSON string
  String toJsonString() => jsonEncode(toJson());

  /// ✅ Convert → Multipart fields (for form-data without files)
  Map<String, String> toFields() {
    final Map<String, String> fields = {
      "project": project,
      "species": species,
      "location": jsonEncode(location),
      "height": height,
      "girth": girth,
      "health_status": healthStatus,
    };

    void addIfNotNull(String key, dynamic value) {
      if (value != null) {
        fields[key] = value.toString();
      }
    }

    addIfNotNull("ownership", ownership);
    addIfNotNull("canopy_diameter", canopyDiameter);
    addIfNotNull("estimated_age", estimatedAge);
    addIfNotNull("soil_type", soilType);
    addIfNotNull("site_quality", siteQuality);
    addIfNotNull("threats", threats);
    addIfNotNull("damage_severity", damageSeverity);
    addIfNotNull("remark", remark);
    addIfNotNull("field_officer", fieldOfficer);

    return fields;
  }

  /// ✅ Centralized validation matching backend logic
  String? validate() {
    final double? h = double.tryParse(height);
    final double? g = double.tryParse(girth);
    final double? cd = canopyDiameter != null && canopyDiameter!.isNotEmpty
        ? double.tryParse(canopyDiameter!)
        : null;

    // 1. Height range check: [0.1, 200.0]
    if (h == null) return "Invalid height value";
    if (h < 0.1 || h > 200.0) {
      return "Height must be between 0.1 and 200.0 meters";
    }

    // 2. Girth range check: [0.01, 20.0]
    if (g == null) return "Invalid girth value";
    if (g < 0.01 || g > 20.0) {
      return "Girth must be between 0.01 and 20.0 meters";
    }

    // 3. Canopy diameter range check: [0.1, 100.0]
    if (cd != null) {
      if (cd < 0.1 || cd > 100.0) {
        return "Canopy diameter must be between 0.1 and 100.0 meters";
      }
    }

    // 4. Image count check: Max 5
    if (images.length > 5) {
      return "Maximum 5 images allowed per survey";
    }

    // 5. Cross-field: Height and girth consistency
    // If height < 0.5 and girth > 1.0 -> Inconsistent
    if (h < 0.5 && g > 1.0) {
      return "Height and girth measurements seem inconsistent";
    }

    // 6. Cross-field: Canopy vs Height
    // If canopy_diameter > height * 2 -> Inconsistent
    if (cd != null && cd > h * 2) {
      return "Canopy diameter seems too large relative to tree height";
    }

    return null; // Valid
  }
}


