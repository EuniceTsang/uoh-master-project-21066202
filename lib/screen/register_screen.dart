import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/blob/Register_cubit.dart';
import 'package:source_code/utils/constants.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return RegisterCubit();
      },
      child: BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
        RegisterCubit cubit = context.read<RegisterCubit>();
        RegisterState state = cubit.state;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft, // Align the first item to the left
                  child: Text('Register',
                      textAlign: TextAlign.left,
                      style:
                      TextStyle(color: Colors.black, fontWeight: FontWeight.w400, fontSize: 30)),
                ),
                SizedBox(height: 40.0),
                CupertinoTextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.text,
                  textAlign: TextAlign.left,
                  // controller: controller.emailEditingController,
                  placeholder: 'Username',
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
                  onChanged: (value) => cubit.usernameChanged(value),
                ),
                SizedBox(height: 16.0),
                CupertinoTextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  textAlign: TextAlign.left,
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
                SizedBox(height: 16.0),
                CupertinoTextField(
                  style: TextStyle(color: Colors.black),
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  textAlign: TextAlign.left,
                  placeholder: 'Confirm your password',
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
                  onChanged: (value) => cubit.confirmPasswordChanged(value),
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
                    cubit.register(context);
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
