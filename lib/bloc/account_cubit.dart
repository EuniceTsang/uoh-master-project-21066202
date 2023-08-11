import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/models/user.dart';
import 'package:source_code/service/firebase_manager.dart';
import 'package:source_code/service/notification_manager.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class AccountCubit extends Cubit<AccountState> {
  late FirebaseManager firebaseManager;
  late NotificationManager notificationManager;

  AccountCubit(BuildContext context) : super(const AccountState()) {
    firebaseManager = context.read<FirebaseManager>();
    notificationManager = context.read<NotificationManager>();
    loadUserData();
  }

  void loadUserData() async {
    AppUser? user = await firebaseManager.getUserData(firebaseManager.uid);
    emit(state.copyWith(targetTime: user?.targetTime, targetReading: user?.targetReading));
  }

  Future<void> logout(BuildContext context) async {
    try {
      await firebaseManager.logout();
      await notificationManager.cancelScheduleNotification();
      await Preferences().clearPrefForLoggedOut();
      Navigator.pushReplacementNamed(context, Constants.routeLogin);
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void clearTargetReading() async {
    try {
      await firebaseManager.updateTargetReading(null);
      emit(state.copyWith(targetTime: null, targetReading: state.targetReading));
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void clearTargetTime() async {
    try {
      await firebaseManager.updateTargetReadingTime(null);
      await Preferences().setTargetTime(state.targetTime ?? '');
      await notificationManager.scheduleNotification();
      emit(state.copyWith(targetTime: state.targetTime, targetReading: null));
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void changeTargetReading(int targetReading) async {
    try {
      await firebaseManager.updateTargetReading(targetReading);
      emit(state.copyWith(targetTime: state.targetTime, targetReading: targetReading));
    } on CustomException catch (e) {
      print(e.message);
    }
  }

  void changeTargetTime(String targetTime) async {
    try {
      await firebaseManager.updateTargetReadingTime(targetTime);
      await Preferences().setTargetTime(targetTime ?? '');
      await notificationManager.scheduleNotification();
      emit(state.copyWith(targetTime: targetTime, targetReading: state.targetReading));
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
