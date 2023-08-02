import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'package:source_code/utils/constants.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void login(BuildContext context) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: "Email and password cannot be empty"));
      return;
    }
    final firebaseManager = context.read<FirebaseManager>();
    final repository = context.read<Repository>();
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    try {
      await firebaseManager.userLogin(state.email, state.password);
      AppUser? user = await firebaseManager.getUserData(FirebaseManager().uid);
      if (user != null) {
        repository.user = user;
      }
      EasyLoading.dismiss();
      Navigator.pushReplacementNamed(context, Constants.routeBaseNavigation);
    } on CustomException catch (e) {
      EasyLoading.dismiss();
      emit(state.copyWith(errorMessage: e.message));
    }
  }

  void passwordChanged(String value) {
    emit(
      state.copyWith(
        password: value,
      ),
    );
  }

  void emailChanged(String value) {
    emit(
      state.copyWith(
        username: value,
      ),
    );
  }
}

class LoginState {
  final String email;
  final String password;
  final String? errorMessage;

  const LoginState({this.email = "", this.password = "", this.errorMessage = ""});

  LoginState copyWith({
    String? username,
    String? password,
    String? errorMessage,
  }) {
    return LoginState(
      email: username ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
