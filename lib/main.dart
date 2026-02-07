import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'common/bloc/location_bloc.dart';
import 'common/bloc/location_event.dart';
import 'common/bloc/location_permission_bloc/location_permission_bloc.dart';
import 'common/bloc/location_permission_bloc/location_permission_state.dart';
import 'core/config/route/app_route.dart';
import 'core/storage/secure_storage.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SecurePreference();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>(
          create: (_) => LocationBloc()..add(StartLocationTracking()),
        ),
          BlocProvider<LocationPermissionBloc>(
          create: (_) => LocationPermissionBloc(),
        ),
      ],
      child: ScreenUtilInit(
      designSize: const Size(360, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title:'Builtree',
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner:false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.config(),
      ),
            ));
  }
}
