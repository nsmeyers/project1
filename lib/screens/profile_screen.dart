import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:project1/functions/firebase_functions.dart';
import 'package:project1/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, pref) {
          int? id = pref.data!.getInt("id");
          String? email = pref.data!.getString("email");
          String? username = pref.data!.getString("username");
          String? pfpString = pref.data!.getString("pfp");
          Uint8List bytes = Uint8List(0);

          if (pfpString != null) {
            bytes = base64Decode(pfpString);
          }

          return Column(
            children: [
              CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
                backgroundImage: (bytes.isEmpty)
                    ? const AssetImage('images/default_pfp.png')
                    : MemoryImage(bytes) as ImageProvider,
              ),
              Text(username!),
              Text(email!),
              Text(id.toString()),

            ],
          );
        },
      ),
    );
  }
}
