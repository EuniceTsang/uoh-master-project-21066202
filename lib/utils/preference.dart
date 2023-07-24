import 'dart:core';

import 'package:get_storage/get_storage.dart';

class Preferences {
  static const String USERNAME_KEY = 'username';
  static const String PASSWORD_KEY = 'password';

  static final Preferences _sharedInstance = Preferences._internal();

  factory Preferences() {
    return _sharedInstance;
  }

  Preferences._internal();

  GetStorage? _storage;

  GetStorage get storage => _getStorage();

  GetStorage _getStorage() {
    _storage ??= GetStorage();
    return _storage!;
  }

  bool get isLoggedIn => !(username == '' || password == '');

  Future<void> setUsername(String username) {
    return _getStorage().write(USERNAME_KEY, username);
  }

  String get username => _getStorage().read(USERNAME_KEY) ?? '';

  Future<void> setPassword(String password) {
    return _getStorage().write(PASSWORD_KEY, password);
  }

  String get password => _getStorage().read(PASSWORD_KEY) ?? '';

  Future<void> savePrefForLoggedIn(String username, String password) async {
    await setUsername(username);
    await setPassword(password);
  }

  Future<void> clearPrefForLoggedOut() async {
    await _getStorage().erase();
  }
}
