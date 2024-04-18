import 'package:flutter/material.dart';
import 'package:project1/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_functions.dart';

void setPersistantData(BuildContext context) {
  SharedPreferences.getInstance().then((prefs) async {
    (String, Map<String, dynamic>) userDoc = await getUserDoc();
    int? userId = prefs.getInt("id");
    if (userId != null) {
      if (userDoc.$2["id"] != userId) {
        prefs.clear();
      }
    }

    await prefs.setString(
      "userDocId",
      userDoc.$1,
    );

    AppUser user = AppUser(
      email: userDoc.$2["email"],
      id: userDoc.$2["id"],
      pfp: userDoc.$2["pfp"],
      username: userDoc.$2["username"],
      docId: userDoc.$1,
    );

    await prefs.setString(
      'email',
      userDoc.$2["email"],
    );
    await prefs.setInt(
      'id',
      userDoc.$2["id"],
    );
    await prefs.setString(
      'pfp',
      userDoc.$2["pfp"],
    );
    await prefs.setString(
      'username',
      userDoc.$2["username"],
    );

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/home",
        arguments: user,
        (route) => false,
      );
    }
  });
}
