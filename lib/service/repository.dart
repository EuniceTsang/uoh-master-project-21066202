import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:source_code/models/user.dart';

class Repository {
  User? user;

  void updateUser(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> map = snapshot.data() as Map<String, dynamic>;
    user = User.fromJson(map);
  }

  void reset() {
    user = null;
  }
}
