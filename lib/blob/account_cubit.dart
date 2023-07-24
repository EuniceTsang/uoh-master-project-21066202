import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:source_code/utils/constants.dart';
import 'package:source_code/utils/preference.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit() : super(const AccountState());

  Future<void> logout(BuildContext context) async {
    await Preferences().clearPrefForLoggedOut();
    Navigator.pushReplacementNamed(context, Constants.routeLogin);
  }
}

class AccountState {
  final int currentTabIndex;

  const AccountState({this.currentTabIndex = 0});
}
