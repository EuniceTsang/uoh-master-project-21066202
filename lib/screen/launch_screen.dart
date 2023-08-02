import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LaunchState();
}

class _LaunchState extends State<LaunchScreen> {
  late FirebaseManager firebaseManager;
  late Repository repository;

  @override
  Widget build(BuildContext context) {
    firebaseManager = context.read<FirebaseManager>();
    repository = context.read<Repository>();
    initData();
    return _LaunchView();
  }

  void initData() async {
    if (!firebaseManager.isLoggedIn) {
      await Preferences().clearPrefForLoggedOut();
      Navigator.pushReplacementNamed(context, Constants.routeLogin);
    } else {
      try {
        AppUser? user = await firebaseManager.getUserData(FirebaseManager().uid);
        if (user != null) {
          repository.user = user;
        }
      } catch (e) {
        print(e);
      }
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
