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
    List<PageRouteInfo>? children,
  }) : super(
         TreeSurveyFormRoute.name,
         args: TreeSurveyFormRouteArgs(
           key: key,
           projectId: projectId,
           latitude: latitude,
           longitude: longitude,
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
  });

  final Key? key;

  final String projectId;

  final double latitude;

  final double longitude;

  @override
  String toString() {
    return 'TreeSurveyFormRouteArgs{key: $key, projectId: $projectId, latitude: $latitude, longitude: $longitude}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TreeSurveyFormRouteArgs) return false;
    return key == other.key &&
        projectId == other.projectId &&
        latitude == other.latitude &&
        longitude == other.longitude;
  }

  @override
  int get hashCode =>
      key.hashCode ^
      projectId.hashCode ^
      latitude.hashCode ^
      longitude.hashCode;
}
