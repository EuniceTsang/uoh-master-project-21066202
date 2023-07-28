import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        QueryDocumentSnapshot snapshot = await firebaseManager.getUserData();
        repository.updateUser(snapshot);
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
