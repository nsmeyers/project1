import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project1/functions/firebase_functions.dart';
import 'package:project1/functions/form_validators.dart';
import 'package:project1/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

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
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, pref) {
            if (pref.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              int? id = pref.data!.getInt("id");
              String? email = pref.data!.getString("email");
              String? username = pref.data!.getString("username");
              String? pfpString = pref.data!.getString("pfp");

              AppUser user = AppUser(
                email: email!,
                id: id!,
                pfp: pfpString!,
                username: username!,
              );

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
                        backgroundImage: (user.pfp == "null")
                            ? const AssetImage('images/default_pfp.png')
                            : MemoryImage(base64Decode(user.pfp))
                                as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? img = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxHeight: 250,
                                maxWidth: 250,
                              );
                              if (img == null) return;

                              File imgFile = File(img.path);
                              String imgString =
                                  base64Encode(imgFile.readAsBytesSync());
                              await user.updatePfp(imgString);
                              setState(() {});
                            },
                            child: const Text("Update"),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              await user.updatePfp("null");
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
                                    hintText: username,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_key.currentState!.validate()) {
                                    await user.updateUsername(
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
                      Text("Email: $email"),
                      const SizedBox(height: 16),
                      Text("ID: ${id.toString()}"),
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
