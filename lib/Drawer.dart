import 'dart:io';

import 'package:clinic_management/DailyAmountGraph.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AuthScreen.dart';
import 'Home.dart';
import 'SecondPage.dart';
import 'historypage.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}




class _DrawerPageState extends State<DrawerPage> {
  File? profileImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }


  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await _auth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthScreen()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<User?>(
            future: FirebaseAuth.instance.authStateChanges().first,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return UserAccountsDrawerHeader(
                  decoration:  BoxDecoration(color: Colors.blue.shade900),
                  accountName: const Text("Loading...", style: TextStyle(color: Colors.white)),
                  accountEmail: const Text(""), // Hides email
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: const AssetImage("assets/profile.jpg"),
                  ),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data?.email == null) {
                return UserAccountsDrawerHeader(
                  decoration:  BoxDecoration(color: Colors.blue.shade900),
                  accountName: const Text("Guest User", style: TextStyle(color: Colors.white)),
                  accountEmail: const Text(""), // Hides email
                  currentAccountPicture: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : const AssetImage("assets/profile.jpg"),
                    ),
                  ),
                );
              } else {
                User user = snapshot.data!;
                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue.shade900),
                  accountName: Text(
                    user.email ?? "No Email",
                    style: const TextStyle(color: Colors.white),
                  ),
                  accountEmail: const Text(""), // Hides email
                  currentAccountPicture: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : const AssetImage("assets/profile.jpg"),
                    ),
                  ),
                );
              }
            },
          ),
          // List of Navigation Items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FirstPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Record page"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("History"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_graph),
            title: const Text("Graph"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => DailyAmountGraph()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () async {
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
