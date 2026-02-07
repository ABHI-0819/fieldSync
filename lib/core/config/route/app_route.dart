import 'package:auto_route/auto_route.dart';
import 'package:fieldsync/common/screens/splash_screen.dart';
import 'package:fieldsync/common/screens/under_development_screen.dart';
import 'package:fieldsync/features/project/screens/select_project_list.dart';
import 'package:flutter/widgets.dart'; 
import '../../../features/authentication/screens/login_screen.dart';
import '../../../features/home/screens/main_screen.dart';
import '../../../features/maps/screens/map_screen.dart';
import '../../../features/project/screens/project_detail_screen.dart';
import '../../../features/project/screens/project_list_screen.dart';
import '../../../features/survey/screens/tree_survey_form.dart';


part 'app_route.gr.dart'; // Generated file

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      path: '/',
      page: SplashRoute.page,
      initial: true, // Makes this the default/initial route
    ),
    AutoRoute(
      path: LoginScreen.route,
      page: LoginRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: MainScreen.route,
      page: MainRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: TreeSurveyFormScreen.route,
      page: TreeSurveyFormRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: MapScreen.route,
      page: MapRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: ProjectDetailScreen.route,
      page: ProjectDetailRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: ProjectListScreen.route,
      page: ProjectListRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: SelectProjectScreen.route,
      page: SelectProjectRoute.page,// Makes this the default/initial route
    ),
    AutoRoute(
      path: UnderDevelopmentScreen.route,
      page: UnderDevelopmentRoute.page,// Makes this the default/initial route
    ),
    // Add more routes here later, e.g., AutoRoute(path: '/home', page: HomeRoute.page)
  ];
}
