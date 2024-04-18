import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project1/functions/firebase_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../styling.dart';
import '../functions/form_validators.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  File? _imgFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _key,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.white,
                  backgroundImage: (_imgFile == null)
                      ? AssetImage('images/default_pfp.png')
                      : FileImage(_imgFile!) as ImageProvider,
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
                        setState(() {
                          _imgFile = File(img.path);
                        });
                      },
                      child: Text("Add Image"),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _imgFile = null;
                      }),
                      child: Text("Remove Image"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  validator: (username) => isUsernameValid(username),
                  decoration: usernameStyling,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  validator: (email) => isEmailValid(email),
                  decoration: emailStyling,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  validator: (password) => isPasswordValid(password),
                  decoration: passwordStyling,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: (confirmPassword) => isPasswordConfirmed(
                    confirmPassword,
                    _passwordController.text,
                  ),
                  decoration: confirmPasswordStyling,
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        signUp(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _imgFile,
                        ).then((value) {
                          if (value != null) {
                            final snackBar = SnackBar(
                              content: Text(value),
                              duration: const Duration(seconds: 2),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            SharedPreferences.getInstance().then((prefs) async {
                              (String, Map<String, dynamic>) userDoc =
                                  await getUserDoc();

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
                            });

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              "/home",
                              (route) => false,
                            );
                          }
                        });
                      } else {
                        const snackBar = SnackBar(
                          content: Text("Please fix incorrect fields"),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    style: signInButtonStyling,
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
