
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LaunchState();

}

class _LaunchState extends State<LaunchScreen> {

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, Preferences().isLoggedIn ? Constants.routeBaseNavigation : Constants.routeLogin);
    });

    return _LaunchView();
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
