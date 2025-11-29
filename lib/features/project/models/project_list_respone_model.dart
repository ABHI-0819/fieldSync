import 'dart:convert';

// Helper functions for easy conversion
ProjectListResponseModel projectListResponseModelFromJson(String str) =>
    ProjectListResponseModel.fromJson(json.decode(str));

String projectListResponseModelToJson(ProjectListResponseModel data) =>
    json.encode(data.toJson());

// Main Model for the entire API response
class ProjectListResponseModel {
  String status;
  String message;
  List<ProjectData> data;

  ProjectListResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectListResponseModel.fromJson(Map<String, dynamic> json) =>
      ProjectListResponseModel(
        status: json["status"],
        message: json["message"],
        // The 'data' field is a list, so we map each item to a ProjectData object
        data: List<ProjectData>.from(
            json["data"].map((x) => ProjectData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

// Model for a single project item inside the 'data' array
class ProjectData {
  String id;
  String pid;
  String name;
  String code;
  String status;
  String priority;
  String organizationName;
  String projectAdminName;
  String locationName;
  DateTime startDate;
  DateTime endDate;
  int expectedTreeCount;
  int daysRemaining;

  ProjectData({
    required this.id,
    required this.pid,
    required this.name,
    required this.code,
    required this.status,
    required this.priority,
    required this.organizationName,
    required this.projectAdminName,
    required this.locationName,
    required this.startDate,
    required this.endDate,
    required this.expectedTreeCount,
    required this.daysRemaining,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) => ProjectData(
    id: json["id"],
    pid: json["pid"],
    name: json["name"],
    code: json["code"],
    status: json["status"],
    priority: json["priority"],
    organizationName: json["organization_name"],
    projectAdminName: json["project_admin_name"],
    locationName: json["location_name"],
    // Parse date strings into DateTime objects
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    expectedTreeCount: json["expected_tree_count"],
    daysRemaining: json["days_remaining"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pid": pid,
    "name": name,
    "code": code,
    "status": status,
    "priority": priority,
    "organization_name": organizationName,
    "project_admin_name": projectAdminName,
    "location_name": locationName,
    // Convert DateTime objects back to ISO 8601 strings
    "start_date": startDate.toIso8601String().split('T').first,
    "end_date": endDate.toIso8601String().split('T').first,
    "expected_tree_count": expectedTreeCount,
    "days_remaining": daysRemaining,
  };
}