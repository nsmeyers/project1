import 'package:flutter/material.dart';

final emailStyling = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  prefixIcon: const Icon(Icons.email),
  hintText: "Enter your email",
  hintStyle: const TextStyle(fontSize: 16),
);

final passwordStyling = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  prefixIcon: const Icon(Icons.password),
  hintText: "Enter your password",
  hintStyle: const TextStyle(fontSize: 16),
);

final confirmPasswordStyling = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  prefixIcon: const Icon(Icons.password),
  hintText: "Confirm your password",
  hintStyle: const TextStyle(fontSize: 16),
);

final usernameStyling = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(5),
  ),
  prefixIcon: const Icon(Icons.person),
  hintText: "Enter your username",
  hintStyle: const TextStyle(fontSize: 16),
);

final signInButtonStyling = ButtonStyle(
  shape: MaterialStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
);

final usernameButtonStyling = ButtonStyle(
  shape: MaterialStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
);