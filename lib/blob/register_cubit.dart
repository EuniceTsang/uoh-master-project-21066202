import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit() : super(const RegisterState());

  Future<void> register(BuildContext context) async {
    if (state.username.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: "Username and password cannot be empty"));
      return;
    } else if (state.confirmPassword.isEmpty) {
      emit(state.copyWith(errorMessage: "Please confirm your password"));
      return;
    } else if (state.confirmPassword != state.password){
      emit(state.copyWith(errorMessage: "Password does not match the confirm password"));
      return;
    }
    Navigator.of(context).pop();
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
}

class RegisterState {
  final String username;
  final String password;
  final String confirmPassword;
  final String? errorMessage;

  const RegisterState(
      {this.username = "", this.password = "", this.confirmPassword = "", this.errorMessage = ""});

  RegisterState copyWith({
    String? username,
    String? password,
    String? confirmPassword,
    String? errorMessage,
  }) {
    return RegisterState(
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      errorMessage: errorMessage,
    );
  }
}
