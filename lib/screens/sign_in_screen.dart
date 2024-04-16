import 'package:flutter/material.dart';

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
          style: TextStyle(
            color: Colors.white
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
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
      body: Container(
        child: Form(
          child: Column(),
        ),
      ),
    );
  }
}
