import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';
import 'package:source_code/screen/base_navigation_screen.dart';
import 'package:source_code/screen/dictionary_screen.dart';
import 'package:source_code/screen/forum_thread_screen.dart';
import 'package:source_code/screen/history_screen.dart';
import 'package:source_code/screen/launch_screen.dart';
import 'package:source_code/screen/login_screen.dart';
import 'package:source_code/screen/reading_screen.dart';
import 'package:source_code/screen/register_screen.dart';
import 'package:source_code/screen/task_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'service/firebase_options.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseManager>(
          create: (_) => FirebaseManager(),
        ),
        RepositoryProvider<Repository>(
          create: (_) => Repository(),
        ),
        // RepositoryProvider.value(
        //   value: FirebaseManager(),
        // ),
        // RepositoryProvider.value(
        //   value: Repository(),
        // ),
      ],
      child: MaterialApp(
          title: 'Master Project',
          theme: ThemeData(
            primarySwatch: Colors.grey,
            scaffoldBackgroundColor: const Color(0xffF6F6F6),
            textSelectionTheme: TextSelectionThemeData(selectionHandleColor: CupertinoColors.systemGrey4)
          ),
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
            Constants.routeReading: (context) => const ReadingScreen(),
            Constants.routeForumThread: (context) => const ForumThreadScreen(),
          }),
    );
  }
}
