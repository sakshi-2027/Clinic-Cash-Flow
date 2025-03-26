import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AuthScreen.dart';
import 'DailyAmountGraph.dart';
import 'Home.dart';
import 'historypage.dart'; // Make sure you have FirstPage in Home.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userId = prefs.getString('userId'); // Check if user ID is stored

  runApp(MyApp(isLoggedIn: userId != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
      // HistoryPage()
      isLoggedIn ? FirstPage() : AuthScreen(),
    );
  }
}







//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
