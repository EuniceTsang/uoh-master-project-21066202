import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/service/firebase_manager.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  Future<void> register(BuildContext context) async {
    final RegExp _emailRegex =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Regular expression to validate email format
    if (state.username.isEmpty ||
        state.password.isEmpty ||
        state.email.isEmpty ||
        state.confirmPassword.isEmpty) {
      emit(state.copyWith(errorMessage: "Please fill in all field"));
      return;
    } else if (state.confirmPassword != state.password) {
      emit(state.copyWith(errorMessage: "Password does not match the confirm password"));
      return;
    } else if (!_emailRegex.hasMatch(state.email)) {
      emit(state.copyWith(errorMessage: "Please enter a valid email"));
      return;
    }
    final firebaseManager = context.read<FirebaseManager>();
    EasyLoading.show();
    try {
      await firebaseManager.userRegister(state.email, state.email, state.password);
      EasyLoading.dismiss();
      Navigator.of(context).pop();
    } on CustomException catch (e) {
      EasyLoading.dismiss();
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  void confirmPasswordChanged(String value) {
    emit(
      state.copyWith(
        confirmPassword: value,
      ),
    );
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
      ),
    );
  }

  void usernameChanged(String value) {
    emit(
      state.copyWith(
        username: value,
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        email: value,
      ),
    );
  }
}

class RegisterState {
  final String email;
  final String username;
  final String password;
  final String confirmPassword;
  final String? errorMessage;

  const RegisterState(
      {this.email = "",
      this.username = "",
      this.password = "",
      this.confirmPassword = "",
      this.errorMessage = ""});

  RegisterState copyWith({
    String? email,
    String? username,
    String? password,
    String? confirmPassword,
    String? errorMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: errorMessage,
    );
  }
}
