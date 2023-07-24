import 'dart:core';

import 'package:get_storage/get_storage.dart';

class Preferences {
  static const String EMAIL_KEY = 'email';
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

  bool get isLoggedIn => !(email == '' || password == '');

  Future<void> setEmail(String email) {
    return _getStorage().write(EMAIL_KEY, email);
  }

  String get email => _getStorage().read(EMAIL_KEY) ?? '';

  Future<void> setPassword(String password) {
    return _getStorage().write(PASSWORD_KEY, password);
  }

  String get password => _getStorage().read(PASSWORD_KEY) ?? '';

  Future<void> savePrefForLoggedIn(String email, String password) async {
    await setEmail(email);
    await setPassword(password);
  }

  Future<void> savePrefForRegistered(String email) async {
    await setEmail(email);
    await setPassword('');
  }

  Future<void> savePrefForLoggedOut() async {
    await _getStorage().erase();
  }
}
