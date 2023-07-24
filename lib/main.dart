import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/screen/base_navigation_screen.dart';
import 'package:source_code/screen/dictionary_screen.dart';
import 'package:source_code/screen/history_screen.dart';
import 'package:source_code/screen/launch_screen.dart';
import 'package:source_code/screen/login_screen.dart';
import 'package:source_code/screen/register_screen.dart';
import 'package:source_code/screen/task_screen.dart';

import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme:
            ThemeData(primarySwatch: Colors.grey, scaffoldBackgroundColor: const Color(0xffF6F6F6)),
        initialRoute: "/launch",
        builder: EasyLoading.init(),
        routes: {
          Constants.routeLaunch: (context) => const LaunchScreen(),
          Constants.routeLogin: (context) => const LoginScreen(),
          Constants.routeRegister: (context) => const RegisterScreen(),
          Constants.routeBaseNavigation: (context) => const BaseNavigationScreen(),
          Constants.routeTask: (context) => const TaskScreen(),
          Constants.routeHistory: (context) => const HistoryScreen(),
          Constants.routeDictionary: (context) => const DictionaryScreen(),
        });
  }
}
