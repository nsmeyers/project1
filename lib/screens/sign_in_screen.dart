import 'package:flutter/material.dart';
import 'package:project1/functions/firebase_functions.dart';

import '../styling.dart';
import '../functions/form_validators.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign In",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/sign-up"),
            child: const Text(
              "Sign Up",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.grey[900],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _key,
            child: Column(
              children: [
                const SizedBox(height: 16),
                SizedBox(
                  height: 350,
                  width: 350,
                  child: Image.asset("images/sign-in.png"),
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
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        signIn(
                          _emailController.text,
                          _passwordController.text,
                        ).then((value) {
                          if (value != null) {
                            final snackBar = SnackBar(
                              content: Text(value),
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
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
                          duration: Duration(seconds: 2),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    },
                    style: signInButtonStyling,
                    child: const Text(
                      "Sign In",
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
