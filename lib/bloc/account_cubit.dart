import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(const AccountState());

  Future<void> logout(BuildContext context) async {
    final firebaseManager = context.read<FirebaseManager>();
    try {
      await firebaseManager.logout();
      await Preferences().clearPrefForLoggedOut();
      Navigator.pushReplacementNamed(context, Constants.routeLogin);
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  void clearTargetReading() {
    String? targetTime = state.targetTime;
    emit(AccountState(targetTime: targetTime));
  }

  void clearTargetTime() {
    int? targetReading = state.targetReading;
    emit(AccountState(targetReading: targetReading));
  }

  void changeTargetReading(int value) {
    emit(state.copyWith(targetReading: value));
  }

  void changeTargetTime(String targetTime) {
    emit(state.copyWith(targetTime: targetTime));
  }
}

class AccountState {
  final int? targetReading;
  final String? targetTime;

  const AccountState({this.targetReading, this.targetTime});

  AccountState copyWith({int? targetReading, String? targetTime}) {
    return AccountState(
      targetReading: targetReading ?? this.targetReading,
      targetTime: targetTime ?? this.targetTime,
    );
  }
}
