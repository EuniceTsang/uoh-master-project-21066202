import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/utils/utils.dart';

class LoginCubit extends Cubit<LoginState> {
  BuildContext context;
  late FirebaseManager firebaseManager;

  LoginCubit(this.context) : super(const LoginState()) {
    firebaseManager = context.read<FirebaseManager>();
  }

  void login() async {
    // data validation
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(errorMessage: "Email and password cannot be empty"));
      return;
    }
    EasyLoading.show(
      maskType: EasyLoadingMaskType.black,
    );
    try {
      //check data in firebase for login
      await firebaseManager.userLogin(state.email, state.password);
      Utils.loginInitialTasks(context);
      EasyLoading.dismiss();
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
        email: value,
      ),
    );
  }
}

class LoginState {
  //data that we need to form the screen
  final String email;
  final String password;
  final String? errorMessage;

  const LoginState({this.email = "", this.password = "", this.errorMessage = ""});

  LoginState copyWith({
    String? email,
    String? password,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
