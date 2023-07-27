import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/bloc/login_cubit.dart';
import 'package:source_code/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return LoginCubit();
      },
      child: BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
        LoginCubit cubit = context.read<LoginCubit>();
        LoginState state = cubit.state;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft, // Align the first item to the left
                  child: Text('Login',
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 30)),
                ),
                SizedBox(height: 40.0),
                CupertinoTextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.left,
                  placeholder: 'Email',
                  placeholderStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.white,
                      darkColor: CupertinoColors.black,
                    ),
                    border: Border.all(
                      color: Colors.black, // Set the border color here
                      width: 2, // Set the border width
                    ),
                  ),
                  onChanged: (value) => cubit.emailChanged(value),
                ),
                SizedBox(height: 16.0),
                CupertinoTextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  obscureText: true,
                  placeholder: 'Password',
                  placeholderStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoDynamicColor.withBrightness(
                      color: CupertinoColors.white,
                      darkColor: CupertinoColors.black,
                    ),
                    border: Border.all(
                      color: Colors.black, // Set the border color here
                      width: 2, // Set the border width
                    ),
                  ),
                  onChanged: (value) => cubit.passwordChanged(value),
                ),
                SizedBox(height: 20.0),
                Text(
                  state.errorMessage ?? '',
                  style: TextStyle(color: Colors.red, fontSize: 15),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, minimumSize: Size(200, 40)),
                  onPressed: () {
                    context.read<LoginCubit>().login(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text('or', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, minimumSize: Size(200, 40)),
                  onPressed: () {
                    Navigator.pushNamed(context, Constants.routeRegister);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
