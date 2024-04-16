String? isEmailValid(String? email) {
  final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (email == null || email.isEmpty) {
    return "Please enter your email";
  } else if (!regex.hasMatch(email)) {
    return "Please enter a valid email";
  } else {
    return null;
  }
}

String? isPasswordValid(String? password) {
  final RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  if (password == null || password.isEmpty) {
    return "Please enter your password";
  } else if (password.length < 6) {
    return "Password is too short";
  } else if (!regex.hasMatch(password)) {
    return "Please enter a valid password";
  } else {
    return null;
  }
}

String? isPasswordConfirmed(String? password, String? confirmedPassword) {
  if (confirmedPassword == null || confirmedPassword.isEmpty) {
    return "Please re-enter your password";
  } else if (password == null || password.isEmpty) {
    return "Please enter your password";
  } else if (confirmedPassword != password) {
    return "Passwords do not match";
  } else {
    return null;
  }
}

String? isUsernameValid(String? username) {
  // Username validation regular expression
  final RegExp regex = RegExp(r'^[a-zA-Z0-9_]+$');
  if (username == null || username.isEmpty) {
    return "Please enter your username";
  } else if (username.length < 3) {
    return "Username must be longer than 3 characters";
  } else if (username.length > 20) {
    return "Username must be shorter than 20 characters";
  } else if (!regex.hasMatch(username)) {
    return "Please enter a valid username";
  } else {
    return null;
  }
}
