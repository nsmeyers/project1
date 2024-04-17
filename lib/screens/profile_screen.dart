import 'package:flutter/material.dart';
import 'package:project1/functions/firebase_functions.dart';
import 'package:project1/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AppUser currentUser;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    currentUser = AppUser.fromMap(await getUserDoc());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: currentUser != null
          ? Column(
              children: [
                Text(currentUser.email),
                Text(currentUser.username),
                // Add more widgets to display user information
              ],
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
