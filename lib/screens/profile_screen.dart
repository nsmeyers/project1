import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project1/functions/choose_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/form_validators.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  final AppUser user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _newUsernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/sign-in",
                (route) => false,
              );
            },
            child: const Text(
              "Sign out",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, pref) {
            if (pref.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              SharedPreferences prefs = pref.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        backgroundImage: (prefs.getString("pfp") == "null")
                            ? const AssetImage('images/default_pfp.png')
                            : MemoryImage(base64Decode(prefs.getString("pfp")!))
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              File? imgFile = await chooseImage();
                              String imgString =
                                  base64Encode(imgFile!.readAsBytesSync());
                              await widget.user.updatePfp(imgString);
                              setState(() {});
                            },
                            child: const Text("Update"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await widget.user.updatePfp("null");
                              setState(() {});
                            },
                            child: const Text("Remove"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        child: const Text("Username"),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: _key,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  validator: (newUsername) =>
                                      isUsernameValid(newUsername),
                                  controller: _newUsernameController,
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(),
                                    hintText: prefs.getString("username"),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_key.currentState!.validate()) {
                                    await widget.user.updateUsername(
                                        _newUsernameController.text);
                                    _newUsernameController.clear();
                                    setState(() {});
                                  }
                                },
                                child: const Text("Update"),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text("Email: ${prefs.getString("email")}"),
                      const SizedBox(height: 16),
                      Text("ID: ${prefs.getInt("id")}"),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
