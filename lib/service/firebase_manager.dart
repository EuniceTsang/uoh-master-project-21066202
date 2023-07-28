import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:source_code/models/user.dart' hide User;
import 'package:source_code/utils/preference.dart';

class FirebaseManager {
  late FirebaseFirestore db;
  late FirebaseAuth auth;

  FirebaseManager() {
    db = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;
  }

  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  String get uid => auth.currentUser?.uid ?? Preferences().uid;

  Future<void> userRegister(String email, String username, String password) async {
    QuerySnapshot querySnapshot =
        await db.collection(UserFields.collection).where(UserFields.email, isEqualTo: email).get();
    if (querySnapshot.docs.isNotEmpty) {
      throw (FirebaseException("Username already taken"));
    }

    try {
      String user_id = await createUser(email, password);

      final user = <String, dynamic>{
        UserFields.user_id: user_id,
        UserFields.username: username,
        UserFields.email: email,
        UserFields.level: 1,
        UserFields.last_level_update: DateTime.now().toString()
      };
      DocumentReference doc = await db.collection(UserFields.collection).add(user);
      print('User added with ID: ${doc.id}');
    } catch (e) {
      print("Register failed: $e");
      throw (FirebaseException("Register failed: $e"));
    }
  }

  Future<String> createUser(String username, String password) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: username,
      password: password,
    );
    return userCredential.user!.uid;
  }

  Future<void> userLogin(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.email, isEqualTo: email)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        String username = querySnapshot.docs.first.get(UserFields.username);
        Preferences().savePrefForLoggedIn(username, user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw (FirebaseException('Incorrect username or password'));
    } catch (e) {
      print(e);
      throw (FirebaseException(e.toString()));
    }
  }

  Future<QueryDocumentSnapshot> getUserData() async {
    try {
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        throw Exception("Cannot find user profile");
      }
    } catch (e) {
      print(e);
      throw (FirebaseException(e.toString()));
    }
  }

  Future<void> updateTargetReading(int? value) async {
    try {
      // Get the reference to the user document using the UID
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;
        await userRef.set(
          {
            UserFields.target_reading: value,
          },
          // This will update the specified field and create it if it doesn't exist
          SetOptions(merge: true),
        );
      } else {
        throw Exception("Cannot find user profile");
      }
      // DocumentReference userRef = db.collection(UserFields.collection).doc(uid);
    } catch (e) {
      print(e);
      throw (FirebaseException(e.toString()));
    }
  }

  Future<void> updateTargetReadingTime(String? time) async {
    try {
      // Get the reference to the user document using the UID
      QuerySnapshot querySnapshot = await db
          .collection(UserFields.collection)
          .where(UserFields.user_id, isEqualTo: uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference userRef = querySnapshot.docs.first.reference;
        await userRef.set(
          {
            UserFields.target_time: time,
          },
          // This will update the specified field and create it if it doesn't exist
          SetOptions(merge: true),
        );
      } else {
        throw Exception("Cannot find user profile");
      }
      // DocumentReference userRef = db.collection(UserFields.collection).doc(uid);
    } catch (e) {
      print(e);
      throw (FirebaseException(e.toString()));
    }
  }

  Future<void> logout() async {
    try {
      await auth.signOut();
      // After signing out, you can navigate to the login page or any other page as needed.
      // For example, you can use Navigator to navigate to the login page:
      // Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error logging out: $e');
      throw (FirebaseException(e.toString()));
    }
  }
}

class FirebaseException implements Exception {
  final String? message;

  FirebaseException(this.message);
}
