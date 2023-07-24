import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  Future<void> login(BuildContext context) async {
    if (state.username.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: "Username and password cannot be empty"));
      return;
    }
    await Preferences().savePrefForLoggedIn(state.username, state.password);
    Navigator.pushReplacementNamed(context, Constants.routeBaseNavigation);
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

class LoginState {
  final String username;
  final String password;
  final String? errorMessage;

  const LoginState({this.username = "", this.password = "", this.errorMessage = ""});

  LoginState copyWith({
    String? username,
    String? password,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
