import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/repository.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class AccountCubit extends Cubit<AccountState> {
  late Repository repository;
  late FirebaseManager firebaseManager;

  AccountCubit(BuildContext context) : super(const AccountState()) {
    repository = context.read<Repository>();
    firebaseManager = context.read<FirebaseManager>();
    loadUserData();
  }

  void loadUserData() {
    User? user = repository.user;
    print(user?.targetTime ?? 'no');
    emit(state.copyWith(targetTime: user?.targetTime, targetReading: user?.targetReading));
  }

  Future<void> logout(BuildContext context) async {
    try {
      await firebaseManager.logout();
      await Preferences().clearPrefForLoggedOut();
      repository.reset();
      Navigator.pushReplacementNamed(context, Constants.routeLogin);
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void clearTargetReading() async {
    try {
      await firebaseManager.updateTargetReading(null);
      repository.user!.targetReading = null;
      loadUserData();
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void clearTargetTime() async {
    try {
      await firebaseManager.updateTargetReadingTime(null);
      repository.user!.targetTime = null;
      loadUserData();
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void changeTargetReading(int value) async {
    try {
      await firebaseManager.updateTargetReading(value);
      repository.user!.targetReading = value;
      loadUserData();
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void changeTargetTime(String targetTime) async {
    try {
      await firebaseManager.updateTargetReadingTime(targetTime);
      repository.user!.targetTime = targetTime;
      loadUserData();
    } on CustomException catch (e) {
      print(e.message);
    }
  }
}

class AccountState {
  final int? targetReading;
  final String? targetTime;

  const AccountState({this.targetReading, this.targetTime});

  AccountState copyWith({int? targetReading, String? targetTime}) {
    return AccountState(
      targetReading: targetReading,
      targetTime: targetTime,
    );
  }
}
