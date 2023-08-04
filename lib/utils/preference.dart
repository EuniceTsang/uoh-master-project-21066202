import 'dart:core';
import 'package:get_storage/get_storage.dart';

class Preferences {
  static const String USERNAME_KEY = 'username';
  static const String UID_KEY = 'uid';

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

  Future<void> setUsername(String username) {
    return _getStorage().write(USERNAME_KEY, username);
  }

  String get username => _getStorage().read(USERNAME_KEY) ?? '';

  Future<void> setUid(String uid) {
    return _getStorage().write(UID_KEY, uid);
  }

  String get uid => _getStorage().read(UID_KEY) ?? '';

  Future<void> savePrefForLoggedIn(String username, String uid) async {
    await setUsername(username);
    await setUid(uid);
  }

  Future<void> clearPrefForLoggedOut() async {
    await _getStorage().erase();
  }
}
