// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_route.dart';

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
}

/// generated route for
/// [MainScreen]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MainScreen();
    },
  );
}

/// generated route for
/// [MapScreen]
class MapRoute extends PageRouteInfo<MapRouteArgs> {
  MapRoute({Key? key, required String projectId, List<PageRouteInfo>? children})
    : super(
        MapRoute.name,
        args: MapRouteArgs(key: key, projectId: projectId),
        initialChildren: children,
      );

  static const String name = 'MapRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MapRouteArgs>();
      return MapScreen(key: args.key, projectId: args.projectId);
    },
  );
}

class MapRouteArgs {
  const MapRouteArgs({this.key, required this.projectId});

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'MapRouteArgs{key: $key, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MapRouteArgs) return false;
    return key == other.key && projectId == other.projectId;
  }

  @override
  int get hashCode => key.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [OfflineProjectsScreen]
class OfflineProjectsRoute extends PageRouteInfo<void> {
  const OfflineProjectsRoute({List<PageRouteInfo>? children})
    : super(OfflineProjectsRoute.name, initialChildren: children);

  static const String name = 'OfflineProjectsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OfflineProjectsScreen();
    },
  );
}

/// generated route for
/// [ProjectDetailScreen]
class ProjectDetailRoute extends PageRouteInfo<ProjectDetailRouteArgs> {
  ProjectDetailRoute({
    Key? key,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
         ProjectDetailRoute.name,
         args: ProjectDetailRouteArgs(key: key, projectId: projectId),
         initialChildren: children,
       );

  static const String name = 'ProjectDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProjectDetailRouteArgs>();
      return ProjectDetailScreen(key: args.key, projectId: args.projectId);
    },
  );
}

class ProjectDetailRouteArgs {
  const ProjectDetailRouteArgs({this.key, required this.projectId});

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'ProjectDetailRouteArgs{key: $key, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProjectDetailRouteArgs) return false;
    return key == other.key && projectId == other.projectId;
  }

  @override
  int get hashCode => key.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [ProjectListScreen]
class ProjectListRoute extends PageRouteInfo<void> {
  const ProjectListRoute({List<PageRouteInfo>? children})
    : super(ProjectListRoute.name, initialChildren: children);

  static const String name = 'ProjectListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProjectListScreen();
    },
  );
}

/// generated route for
/// [ResourceSyncScreen]
class ResourceSyncRoute extends PageRouteInfo<ResourceSyncRouteArgs> {
  ResourceSyncRoute({
    Key? key,
    required String projectId,
    List<PageRouteInfo>? children,
  }) : super(
         ResourceSyncRoute.name,
         args: ResourceSyncRouteArgs(key: key, projectId: projectId),
         initialChildren: children,
       );

  static const String name = 'ResourceSyncRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResourceSyncRouteArgs>();
      return ResourceSyncScreen(key: args.key, projectId: args.projectId);
    },
  );
}

class ResourceSyncRouteArgs {
  const ResourceSyncRouteArgs({this.key, required this.projectId});

  final Key? key;

  final String projectId;

  @override
  String toString() {
    return 'ResourceSyncRouteArgs{key: $key, projectId: $projectId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResourceSyncRouteArgs) return false;
    return key == other.key && projectId == other.projectId;
  }

  @override
  int get hashCode => key.hashCode ^ projectId.hashCode;
}

/// generated route for
/// [SelectProjectScreen]
class SelectProjectRoute extends PageRouteInfo<void> {
  const SelectProjectRoute({List<PageRouteInfo>? children})
    : super(SelectProjectRoute.name, initialChildren: children);

  static const String name = 'SelectProjectRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SelectProjectScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TreeSurveyFormScreen]
class TreeSurveyFormRoute extends PageRouteInfo<TreeSurveyFormRouteArgs> {
  TreeSurveyFormRoute({
    Key? key,
    required String projectId,
    required double latitude,
    required double longitude,
    bool isOfflineMode = false,
    List<PageRouteInfo>? children,
  }) : super(
         TreeSurveyFormRoute.name,
         args: TreeSurveyFormRouteArgs(
           key: key,
           projectId: projectId,
           latitude: latitude,
           longitude: longitude,
           isOfflineMode: isOfflineMode,
         ),
         initialChildren: children,
       );

  static const String name = 'TreeSurveyFormRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TreeSurveyFormRouteArgs>();
      return TreeSurveyFormScreen(
        key: args.key,
        projectId: args.projectId,
        latitude: args.latitude,
        longitude: args.longitude,
        isOfflineMode: args.isOfflineMode,
      );
    },
  );
}

class TreeSurveyFormRouteArgs {
  const TreeSurveyFormRouteArgs({
    this.key,
    required this.projectId,
    required this.latitude,
    required this.longitude,
    this.isOfflineMode = false,
  });

  final Key? key;

  final String projectId;

  final double latitude;

  final double longitude;

  final bool isOfflineMode;

  @override
  String toString() {
    return 'TreeSurveyFormRouteArgs{key: $key, projectId: $projectId, latitude: $latitude, longitude: $longitude, isOfflineMode: $isOfflineMode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TreeSurveyFormRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        isOfflineMode == other.isOfflineMode;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      projectId.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      isOfflineMode.hashCode;
}

/// generated route for
/// [UnderDevelopmentScreen]
class UnderDevelopmentRoute extends PageRouteInfo<UnderDevelopmentRouteArgs> {
  UnderDevelopmentRoute({
    Key? key,
    String? featureName,
    String? message,
    List<PageRouteInfo>? children,
  }) : super(
         UnderDevelopmentRoute.name,
         args: UnderDevelopmentRouteArgs(
           key: key,
           featureName: featureName,
           message: message,
         ),
         initialChildren: children,
       );

  static const String name = 'UnderDevelopmentRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UnderDevelopmentRouteArgs>(
        orElse: () => const UnderDevelopmentRouteArgs(),
      );
      return UnderDevelopmentScreen(
        key: args.key,
        featureName: args.featureName,
        message: args.message,
      );
    },
  );
}

class UnderDevelopmentRouteArgs {
  const UnderDevelopmentRouteArgs({this.key, this.featureName, this.message});

  final Key? key;

  final String? featureName;

  final String? message;

  @override
  String toString() {
    return 'UnderDevelopmentRouteArgs{key: $key, featureName: $featureName, message: $message}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UnderDevelopmentRouteArgs) return false;
    return key == other.key &&
        featureName == other.featureName &&
        message == other.message;
  }

  @override
  int get hashCode => key.hashCode ^ featureName.hashCode ^ message.hashCode;
}
