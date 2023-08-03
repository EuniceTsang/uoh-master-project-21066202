import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LaunchState();
}

class _LaunchState extends State<LaunchScreen> {
  late FirebaseManager firebaseManager;

  @override
  Widget build(BuildContext context) {
    firebaseManager = context.read<FirebaseManager>();
    initData();
    return _LaunchView();
  }

  void initData() async {
    if (!firebaseManager.isLoggedIn) {
      await Preferences().clearPrefForLoggedOut();
      Navigator.of(context).pushNamedAndRemoveUntil(Constants.routeLogin,(Route<dynamic> route) => false);
    } else {
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context).pushNamedAndRemoveUntil(Constants.routeBaseNavigation,(Route<dynamic> route) => false);
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
