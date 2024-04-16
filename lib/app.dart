import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';

class Project1 extends StatelessWidget {
  const Project1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "/sign-in",
      routes: {
        "/sign-in": (context) => const SignInScreen(),
        "/sign-up": (context) => const SignUpScreen(),
        "/home": (context) => const HomeScreen(),
      },
    );
  }
}