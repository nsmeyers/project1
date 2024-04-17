import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> signUp(
    String username, String email, String password, File? pfp) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName(username);

    // Get the current user count
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("metadata")
        .doc("user_count")
        .get();
    int userCount = (snapshot.exists
            ? (snapshot.data()! as Map<String, dynamic>)['count']
            : 0) +
        1;

    Map<String, dynamic> userData = {
      "uid": userCredential.user!.uid,
      "id": userCount,
      "email": userCredential.user!.email,
      "username": username,
    };

    if (pfp != null) {
      userData["pfp"] = base64Encode(pfp.readAsBytesSync());
    }

    FirebaseFirestore.instance.collection("users").add(userData);

    // Update the user count in Firestore
    await FirebaseFirestore.instance
        .collection("metadata")
        .doc("user_count")
        .set({
      "count": userCount,
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

Future<Map<String, dynamic>> getUserDoc() async {
  String userUid = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot userDocs = await FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: userUid)
      .get();
  DocumentSnapshot userDoc = userDocs.docs[0];
  Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
  return userData;
}
