import 'dart:convert';

// Helper functions for easy conversion
ProjectDashboardResponse projectDashboardResponseFromJson(String str) =>
    ProjectDashboardResponse.fromJson(json.decode(str));

String projectDashboardResponseToJson(ProjectDashboardResponse data) =>
    json.encode(data.toJson());

/// --- 1. Main Model for the entire API response ---
class ProjectDashboardResponse {
  final String status;
  final String message;
  final DashboardData data;

  ProjectDashboardResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ProjectDashboardResponse.fromJson(Map<String, dynamic> json) =>
      ProjectDashboardResponse(
        status: json["status"] as String? ?? '',
        message: json["message"] as String? ?? '',
        data: DashboardData.fromJson(json["data"] as Map<String, dynamic>? ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

/// --- 2. Model for the 'data' payload ---
class DashboardData {
  final ProjectOverview overview;
  final ProjectStats stats;
  final List<TeamMember> teamMembers;
  final List<SurveyProgress> surveyProgress;
  final List<dynamic> speciesDistribution; // dynamic since we don't know the structure
  final List<dynamic> healthDistribution; // dynamic since we don't know the structure
  final List<dynamic> recentSurveys; // dynamic since we don't know the structure
  final List<ProjectAction> projectActions;
  final DateTime? generatedAt;

  DashboardData({
    required this.overview,
    required this.stats,
    required this.teamMembers,
    required this.surveyProgress,
    required this.speciesDistribution,
    required this.healthDistribution,
    required this.recentSurveys,
    required this.projectActions,
    this.generatedAt,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // Helper function for safe DateTime parsing
    DateTime? safeParseDate(dynamic date) {
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    // Helper for safe list parsing
    List<T> safeListParse<T>(
        dynamic listJson, T Function(Map<String, dynamic>) fromJson) {
      if (listJson is List) {
        return listJson
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
      return [];
    }

    return DashboardData(
      overview: ProjectOverview.fromJson(
          json["project_overview"] as Map<String, dynamic>? ?? {}),
      stats: ProjectStats.fromJson(
          json["project_stats"] as Map<String, dynamic>? ?? {}),
      teamMembers: safeListParse<TeamMember>(
          json["team_members"], TeamMember.fromJson),
      surveyProgress: safeListParse<SurveyProgress>(
          json["survey_progress"], SurveyProgress.fromJson),
      speciesDistribution: json["species_distribution"] as List? ?? [],
      healthDistribution: json["health_distribution"] as List? ?? [],
      recentSurveys: json["recent_surveys"] as List? ?? [],
      projectActions: safeListParse<ProjectAction>(
          json["project_actions"], ProjectAction.fromJson),
      generatedAt: safeParseDate(json["generated_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "project_overview": overview.toJson(),
    "project_stats": stats.toJson(),
    "team_members": List<dynamic>.from(teamMembers.map((x) => x.toJson())),
    "survey_progress":
    List<dynamic>.from(surveyProgress.map((x) => x.toJson())),
    "species_distribution": speciesDistribution,
    "health_distribution": healthDistribution,
    "recent_surveys": recentSurveys,
    "project_actions":
    List<dynamic>.from(projectActions.map((x) => x.toJson())),
    "generated_at": generatedAt?.toIso8601String(),
  };
}

// -------------------------------------------------------------------
// --- 3. Nested Models ---
// -------------------------------------------------------------------

/// --- ProjectOverview ---
class ProjectOverview {
  final String id;
  final String name;
  final String code;
  final String status;
  final String locationName;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectAdmin projectAdmin;
  final Organization organization;

  ProjectOverview({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    required this.locationName,
    this.startDate,
    this.endDate,
    required this.projectAdmin,
    required this.organization,
  });

  factory ProjectOverview.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic date) {
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return ProjectOverview(
      id: json["id"] as String? ?? '',
      name: json["name"] as String? ?? '',
      code: json["code"] as String? ?? '',
      status: json["status"] as String? ?? '',
      locationName: json["location_name"] as String? ?? '',
      startDate: safeParseDate(json["start_date"]),
      endDate: safeParseDate(json["end_date"]),
      projectAdmin: ProjectAdmin.fromJson(
          json["project_admin"] as Map<String, dynamic>? ?? {}),
      organization: Organization.fromJson(
          json["organization"] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "status": status,
    "location_name": locationName,
    "start_date": startDate?.toIso8601String().split('T').first,
    "end_date": endDate?.toIso8601String().split('T').first,
    "project_admin": projectAdmin.toJson(),
    "organization": organization.toJson(),
  };
}

/// --- ProjectAdmin ---
class ProjectAdmin {
  final String id;
  final String name;
  final String email;
  final String phone;

  ProjectAdmin({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory ProjectAdmin.fromJson(Map<String, dynamic> json) => ProjectAdmin(
    id: json["id"] as String? ?? '',
    name: json["name"] as String? ?? '',
    email: json["email"] as String? ?? '',
    phone: json["phone"] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
  };
}

/// --- Organization ---
class Organization {
  final String id;
  final String name;

  Organization({
    required this.id,
    required this.name,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json["id"] as String? ?? '',
    name: json["name"] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

/// --- ProjectStats ---
class ProjectStats {
  final int teamSize;
  final int totalSurveys;
  final int completedSurveys;
  final int totalTrees;
  final int speciesDiversity;
  final double totalCarbonSequestered;
  final double averageTreeHeight;
  final double areaHectares;

  ProjectStats({
    required this.teamSize,
    required this.totalSurveys,
    required this.completedSurveys,
    required this.totalTrees,
    required this.speciesDiversity,
    required this.totalCarbonSequestered,
    required this.averageTreeHeight,
    required this.areaHectares,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    // Helper for safe integer parsing
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    // Helper for safe double parsing
    double safeParseDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return ProjectStats(
      teamSize: safeParseInt(json["team_size"]),
      totalSurveys: safeParseInt(json["total_surveys"]),
      completedSurveys: safeParseInt(json["completed_surveys"]),
      totalTrees: safeParseInt(json["total_trees"]),
      speciesDiversity: safeParseInt(json["species_diversity"]),
      totalCarbonSequestered: safeParseDouble(json["total_carbon_sequestered"]),
      averageTreeHeight: safeParseDouble(json["average_tree_height"]),
      areaHectares: safeParseDouble(json["area_hectares"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "team_size": teamSize,
    "total_surveys": totalSurveys,
    "completed_surveys": completedSurveys,
    "total_trees": totalTrees,
    "species_diversity": speciesDiversity,
    "total_carbon_sequestered": totalCarbonSequestered,
    "average_tree_height": averageTreeHeight,
    "area_hectares": areaHectares,
  };
}

/// --- TeamMember ---
class TeamMember {
  final String userId;
  final String userProfileFirstName;
  final String userProfileLastName;
  final String userEmail;
  final String userPhoneNumber;
  final DateTime? createdAt;

  TeamMember({
    required this.userId,
    required this.userProfileFirstName,
    required this.userProfileLastName,
    required this.userEmail,
    required this.userPhoneNumber,
    this.createdAt,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    DateTime? safeParseDate(dynamic date) {
      if (date is String) {
        try {
          return DateTime.parse(date);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return TeamMember(
      userId: json["user__id"] as String? ?? '',
      userProfileFirstName: json["user__profile__first_name"] as String? ?? '',
      userProfileLastName: json["user__profile__last_name"] as String? ?? '',
      userEmail: json["user__email"] as String? ?? '',
      userPhoneNumber: json["user__phone_number"] as String? ?? '',
      createdAt: safeParseDate(json["created_at"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "user__id": userId,
    "user__profile__first_name": userProfileFirstName,
    "user__profile__last_name": userProfileLastName,
    "user__email": userEmail,
    "user__phone_number": userPhoneNumber,
    "created_at": createdAt?.toIso8601String(),
  };
}

/// --- SurveyProgress ---
class SurveyProgress {
  final String month;
  final String monthName;
  final int surveysCount;
  final double carbonSequestered;

  SurveyProgress({
    required this.month,
    required this.monthName,
    required this.surveysCount,
    required this.carbonSequestered,
  });

  factory SurveyProgress.fromJson(Map<String, dynamic> json) {
    int safeParseInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }
    double safeParseDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SurveyProgress(
      month: json["month"] as String? ?? '',
      monthName: json["month_name"] as String? ?? '',
      surveysCount: safeParseInt(json["surveys_count"]),
      carbonSequestered: safeParseDouble(json["carbon_sequestered"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "month": month,
    "month_name": monthName,
    "surveys_count": surveysCount,
    "carbon_sequestered": carbonSequestered,
  };
}

/// --- ProjectAction ---
class ProjectAction {
  final String action;
  final String title;
  final String description;
  final String endpoint;
  final String method;

  ProjectAction({
    required this.action,
    required this.title,
    required this.description,
    required this.endpoint,
    required this.method,
  });

  factory ProjectAction.fromJson(Map<String, dynamic> json) => ProjectAction(
    action: json["action"] as String? ?? '',
    title: json["title"] as String? ?? '',
    description: json["description"] as String? ?? '',
    endpoint: json["endpoint"] as String? ?? '',
    method: json["method"] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    "action": action,
    "title": title,
    "description": description,
    "endpoint": endpoint,
    "method": method,
  };
}