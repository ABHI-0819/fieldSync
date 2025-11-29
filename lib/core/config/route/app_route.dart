import 'package:fieldsync/features/authentication/screens/login_screen.dart';
import 'package:fieldsync/features/home/screens/main_screen.dart';
import 'package:fieldsync/features/maps/screens/map_screen.dart';
import 'package:flutter/material.dart';

import '../../../common/screens/screen_404.dart';
import '../../../features/project/screens/project_detail_screen.dart';
import '../../../features/survey/screens/tree_survey_form.dart';


class AppRoute{
  Route onGenerateRoute(RouteSettings settings){
    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/main-screen':
        return MaterialPageRoute(builder: (_) => MainScreen());
      case '/map':
        Map? argument = settings.arguments as Map?;
        return MaterialPageRoute(builder: (_) => MapScreen(
          projectId: argument!['projectId'],
        ));
      case '/project-detail':
        Map? argument = settings.arguments as Map?;
        return MaterialPageRoute(builder: (_) => ProjectDetailScreen(
          projectId: argument!['projectId'],
        ));
      case '/TreeSurveyForm':
        Map? argument = settings.arguments as Map?;
        return MaterialPageRoute(builder: (_) => TreeSurveyFormScreen(
            projectId: argument!['projectId'],
            latitude :argument['latitude'],
            longitude: argument['longitude'],
        ));
      default:
        return  MaterialPageRoute(builder: (_) => const Screen404(
          title: "404",
          message: "'This is a Dead End'",
        ));
    }
  }

  static void goToNextPage({ required BuildContext context,  required String screen, required Map arguments}) {
    Navigator.pushNamed(context, screen,arguments: arguments);
  }

  static void pop(BuildContext context) {
    Navigator.canPop(context) ? Navigator.of(context).pop() : _showErrorCantGoBack(context);
  }

  static void  pushReplacement(BuildContext context, String routeName, { required Map arguments, screen}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }


  static void popUntil(BuildContext context,String routeName,{required Map arguments}){
    Navigator.of(context).popUntil(ModalRoute.withName(routeName));
  }

  static void pushAndRemoveUntil(BuildContext context, String routeName, {required Map arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
          (Route<dynamic> route) => false,
      arguments: arguments,
    );
  }

  static void pushAndRemoveUntilNamed(
      BuildContext context,
      String routeToPush,
      String untilRouteName, {
        Map<String, dynamic>? arguments,
      }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeToPush,
      ModalRoute.withName(untilRouteName),
      arguments: arguments,
    );
  }

  static _showErrorCantGoBack(BuildContext context) {
    const SnackBar(
      content: Text(
        'Oops! Something went wrong. There are no previous screens to navigate back to.',
        style: TextStyle(fontSize: 16),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
    );
  }
}
//No Screen to go Back