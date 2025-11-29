import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/config/route/app_route.dart';
import 'core/storage/secure_storage.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SecurePreference();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title:'TREE-SYNC',
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner:false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/',
        onGenerateRoute: AppRoute().onGenerateRoute,
      ),
    );
  }
}
