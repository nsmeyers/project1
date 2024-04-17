import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> signUp(String username, String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName(username);

    FirebaseFirestore.instance.collection("users").add({
      "uid": userCredential.user!.uid,
    });

    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<String?> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return null;
  } on FirebaseAuthException catch (e) {
    return e.message;
  } on Exception catch (e) {
    return e.toString();
  }
}

Future<int> getUserId() async {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot userDocs = await FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: userUid)
      .get();
  DocumentSnapshot userDoc = userDocs.docs[0];
  Map userData = userDoc.data() as Map;
  return userData["id"] as int;
}
