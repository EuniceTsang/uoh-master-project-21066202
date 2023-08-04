import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/task_manager.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LaunchState();
}

class _LaunchState extends State<LaunchScreen> {
  late FirebaseManager firebaseManager;
  late TaskManager taskManager;

  @override
  Widget build(BuildContext context) {
    return _LaunchView();
  }

  @override
  void initState() {
    firebaseManager = context.read<FirebaseManager>();
    taskManager = context.read<TaskManager>();
    initData();
    super.initState();
  }

  void initData() async {
    if (!firebaseManager.isLoggedIn) {
      await Preferences().clearPrefForLoggedOut();
      Navigator.pushReplacementNamed(context, Constants.routeLogin);
    } else {
      await taskManager.loadTask();
      Navigator.pushReplacementNamed(context, Constants.routeBaseNavigation);
    }
  }
}

class _LaunchView extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      );
}
