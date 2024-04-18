import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_functions.dart';

void setPersistantData(BuildContext context) {
  SharedPreferences.getInstance().then((prefs) async {
    prefs.clear();
    (String, Map<String, dynamic>) userDoc = await getUserDoc();

    await prefs.setString(
      "userDocId",
      userDoc.$1,
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
        (route) => false,
      );
    }
  });
}
